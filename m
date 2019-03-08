Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56C96C10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:11:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15F13206DF
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 19:11:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15F13206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 929598E0004; Fri,  8 Mar 2019 14:11:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D92D8E0002; Fri,  8 Mar 2019 14:11:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C7A48E0004; Fri,  8 Mar 2019 14:11:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 53C6C8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 14:11:17 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id i21so289025qtq.6
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 11:11:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/kAshcJVUFY8th2kNU5RPGLHDu41rQnev1whK2dp3F8=;
        b=GonwjFngyZuj6qmH33k80V47I+FhZcGvCl3lDb1y2p12/9qcb/sJq+k3sOB4U02+KN
         2GAE24D8yO28tH3RQpseCxh9fYNhpJSzOclPV12DhNIX4Un/f4TH7HYRSr3L2jK3/M+k
         hVCa2Yr/gc5bkqio8DOvWxh0nFK/NA6njsFO1gZVFourjzowInZ7MxtQjhJ+lyWc0slI
         X/WadS4y22vOcXF0Ez8cHuMJwMvYlW87SyT6NM7rOXfB2U5SjpNxHKfnJUUCGC7K/J2C
         ue3rPouPjl2R+FPJ1eiILIuE7lC/1fVjX5hTj1F3Y1nQCf0TgfNZxopt6Ipg6aoxRQWX
         Mu5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUj/OSmjfM3jiQ4ztfiU8A/aWl7Zf8zzEa2MOXaTHV0WA43SFXm
	QFSFm2XVPDpYMvu3ztXvzkOBeFQ5hgJ5tauqL8xhGe+nXzwaH9BCu0Z7WbYXRifBmeEyW9qhfar
	p/RDorRWsRrw4Nz3DqcEawBCgiF8I3amUMKqvo//LGj5eYc2H4OroJrtlJpkNmMnWBA==
X-Received: by 2002:a0c:9e2d:: with SMTP id p45mr16325892qve.28.1552072277136;
        Fri, 08 Mar 2019 11:11:17 -0800 (PST)
X-Google-Smtp-Source: APXvYqzDIIwDVIH194IiUiJf6onhLyLy3FNeGftrwxWKAbXV8lAZ1rHjcyi93KDOdWxCbVV/kOn1
X-Received: by 2002:a0c:9e2d:: with SMTP id p45mr16325844qve.28.1552072276427;
        Fri, 08 Mar 2019 11:11:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552072276; cv=none;
        d=google.com; s=arc-20160816;
        b=MTDCbEmWB+HLnbAhCu6WaIJgpvU61UsFxS5WcOo0uHe056cWVULmqrjCmHCNeRHkFW
         dwkGpW984/vKxN6OyJlkO9kkAJlhufjkymPbgQFUaOBWpd6z6VPo5VnFs7fAhs8WJadD
         yYaMdZVHubzk1L8PncOo3JHXEEIs9kdwHYtdVl6YOZROA9yC5KhD8+Dsqrq3UETBYDiX
         liANYFUN6ngS/XAK/pk03dGu44AAcaQHwQC4m12ZB+p5TwxOOYYdI9sGwJ/StH6xxAf9
         moEU3mXpCVevEJy8TCXK6L8q7lsZiW2yTKPIWiKlYB2latVZNgkw4yCLOC78rLWloOXJ
         CNxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/kAshcJVUFY8th2kNU5RPGLHDu41rQnev1whK2dp3F8=;
        b=n2rw8wlWaFQEHrN766HEgbl+wY+VBpxCEBD8nfgENxty7UY31zTGZD0tRYusV7Mxm8
         e6TVOlidjy+G/p1wwutKwv0bHjVjO1mCX2VjmBAFnhLra6bVckjUKOEyrDTvE4CDZay2
         qJ+AcJCghVaN6AYzhCOFozNYYBfyRVJ2exnYobq7EdIUEyCS3syN40fEixlIuWcJmMD9
         JqUfzmwsZgUbo+xE3eJ3LiymJ55qHeSeEFqouC0Zof6VFnTQMxvr/QROt2xYLy/NX30s
         5qlK0WHs7XGc+8OQiIQ9zGd5WZnlFjq+D+3wu4ScfwaiBJ/SVN1qFcCrP2xaPE3XPuz4
         OC4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q33si5107985qvc.139.2019.03.08.11.11.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 11:11:16 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8ED46C05D261;
	Fri,  8 Mar 2019 19:11:15 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id EDECF60856;
	Fri,  8 Mar 2019 19:11:08 +0000 (UTC)
Date: Fri, 8 Mar 2019 14:11:08 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308191108.GA26923@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
 <20190307190910.GE3835@redhat.com>
 <20190307193838.GQ23850@redhat.com>
 <20190307201722.GG3835@redhat.com>
 <20190307212717.GS23850@redhat.com>
 <671c4a98-4699-836e-79fc-0ce650c7f701@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <671c4a98-4699-836e-79fc-0ce650c7f701@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 08 Mar 2019 19:11:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 05:13:26PM +0800, Jason Wang wrote:
> Actually not wrapping around,  the pages for used ring was marked as 
> dirty after a round of virtqueue processing when we're sure vhost wrote 
> something there.

Thanks for the clarification. So we need to convert it to
set_page_dirty and move it to the mmu notifier invalidate but in those
cases where gup_fast was called with write=1 (1 out of 3).

If using ->invalidate_range the page pin also must be removed
immediately after get_user_pages returns (not ok to hold the pin in
vmap until ->invalidate_range is called) to avoid false positive gup
pin checks in things like KSM, or the pin must be released in
invalidate_range_start (which is called before the pin checks).

Here's why:

		/*
		 * Check that no O_DIRECT or similar I/O is in progress on the
		 * page
		 */
		if (page_mapcount(page) + 1 + swapped != page_count(page)) {
			set_pte_at(mm, pvmw.address, pvmw.pte, entry);
			goto out_unlock;
		}
		[..]
		set_pte_at_notify(mm, pvmw.address, pvmw.pte, entry);
			  ^^^^^^^ too late release the pin here, the
				  above already failed

->invalidate_range cannot be used with mutex anyway so you need to go
back with invalidate_range_start/end anyway, just the pin must be
released in _start at the latest in such case.

My prefer is generally to call gup_fast() followed by immediate
put_page() because I always want to drop FOLL_GET from gup_fast as a
whole to avoid 2 useless atomic ops per gup_fast.

I'll write more about vmap in answer to the other email.

Thanks,
Andrea

