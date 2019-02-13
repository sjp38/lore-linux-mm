Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F871C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:15:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4B4A222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 15:15:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4B4A222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 605118E0003; Wed, 13 Feb 2019 10:15:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B38A8E0001; Wed, 13 Feb 2019 10:15:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CA6B8E0003; Wed, 13 Feb 2019 10:15:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 038BE8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 10:15:53 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y91so1132043edy.21
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 07:15:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ArmSqIbV3LsOKgwrxdb0IuS/d8JAp2JKvciotgSOJeU=;
        b=LtjDVdl8cgBOahxZ48AMWqr4ro/zzP3sIfnQDGmuBtBKvNBxQVF4P84nOs4Pz118oB
         kZtylQs9LMBNqb0RfxwjKdQ+0EDEQkOvb/cFcgdTSYupsnkAf+IsL64nnh2GvRabrzcD
         QTUu3XgwtcfTrN3yl8CLqDn+qpL5qjlsmpzFBmFWHvesnROZj9wd2l97ahkMvOB+lW5r
         jh+lyjekIWiofeNKqnGpIqE86tNY1Q8ea5Q0AsbmAZ0C40MeZPfDjiFDBC7it+Oky6X/
         nMbxVZut4UyQCvAqviE/akAMoidabDn1G+zd5XFe25ibu6Q/JoLP+BWKlGpNrelHSTqe
         76Mg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAubpc6mg+s4cey7YcnkMj8MTGDlWfgJYNakC4WFfylfB1CWcIxPm
	epsjiYb6oN2o7+nadkMkWoq8xPgaUrVid/s8reFSwjZiVGIwbsfyEMdod8LIonGE+B0m7Zptevu
	FtaaU0u8IbxEovJf88+xooTUkNxrsRGdxVepiWkvzpDO3rSaHBvnmJszBbwQUM24=
X-Received: by 2002:a17:906:7cd0:: with SMTP id h16mr764966ejp.126.1550070952528;
        Wed, 13 Feb 2019 07:15:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZMvMD75/4rz0NyuWNrnYxm85mBIIuLj05Ef9JRn6MeTF+XmPWTF3Uqav1DCNDdRCmTMSp
X-Received: by 2002:a17:906:7cd0:: with SMTP id h16mr764918ejp.126.1550070951707;
        Wed, 13 Feb 2019 07:15:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550070951; cv=none;
        d=google.com; s=arc-20160816;
        b=mj0dHoo0qX4QaK4gfm9uIiPaPHeay/NX1jpjOyDqcMzyPJWV4UxgW8bAh6NsPZvuaL
         MZQsgm6K8JkxyDVq7wv0oGRiE0riXJ4sRySE/mLIwrOGGI6yc3woxvfEE7kK1sbhvvU8
         um2B9oU60sbsbwcXcAeNmN6NYF4iGJxzbZC3xgoufLxlHmkLb8yN2tsguJHwRX/VKpMu
         eRwFpEUrvn7cG6yatlRpq3Q58Volkt1LrwwAXnX15EG5YdRNSfrUfSSPbqBT7CtcLAbq
         d/O4WEAlfuWA4ZqaGA1FIGUhGZuD03xkVKOKzHMIawUQ1UhYIK96gm88oDIhnac3iIHh
         WKsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ArmSqIbV3LsOKgwrxdb0IuS/d8JAp2JKvciotgSOJeU=;
        b=or+reH3xbGawgiUOPyZ9PFHBQXy1c/XOmx254gepodBcXo1iH3XguOaSAoXQCmePyH
         WNACWRRN9hUbkt3WoGJBSrza9gOYD/Q2aEe5NQAmgYUk7rH9ZjXWvx7mZgV3ANx4jRdk
         2Lap/dfxYou2yqz08hVepcCAcbd80Zc5FYSjf30KIC4YEyhzKjP3zM/EmJ5TimVc3yz4
         ZEHXFXEm+udnmk5gcU9P4haNJVJKonELJqmf8tixr7O59aQfHbK69KX4oRij7yObISTc
         zTYJuigFuc4TaghQAeTZV0KxkFRAhfvUZ3EnC2ysA0HZbBFHUc9IvCUSIbgg8BBp7VRT
         Cb0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id 3si49858edz.362.2019.02.13.07.15.51
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 07:15:51 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id A041F4278; Wed, 13 Feb 2019 16:15:50 +0100 (CET)
Date: Wed, 13 Feb 2019 16:15:50 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, akpm@linux-foundation.org,
	david@redhat.com, anthony.yznaga@oracle.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm,memory_hotplug: Explicitly pass the head to
 isolate_huge_page
Message-ID: <20190213151547.cwaqptreai43s65j@d104.suse.de>
References: <20190208090604.975-1-osalvador@suse.de>
 <20190212083329.GN15609@dhcp22.suse.cz>
 <20190212134546.gubfir6zzwrvmunr@d104.suse.de>
 <20190212144026.GY15609@dhcp22.suse.cz>
 <52f7a47c-4a8b-c06d-04c0-48d9bb43823b@oracle.com>
 <20190213081310.zfxwb3svoqsxnuyc@d104.suse.de>
 <20190213123339.GG4525@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213123339.GG4525@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:33:39PM +0100, Michal Hocko wrote:
> Why isn't our check in has_unmovable_pages sufficient?

Taking a closer look, it should be enough.
I was mainly confused by the fact that if the zone is ZONE_MOVABLE,
we do not keep checking in has_unmovable_pages():

if (zone_idx(zone) == ZONE_MOVABLE)
	continue;

But I overlooked that htlb_alloc_mask() checks whether the allocation
cand end up in a movable zone.
hugepage_movable_supported() checks that and if the hstate does not
support migration at all, we skip __GFP_MOVABLE.

So I think that the check in has_unmovable_pages() should be more than enough,
so we could strip the checks from do_migrate_ranges() and
scan_movable_pages() regarding hugepage migratability.

I will run some tests just to make sure this holds and then
I will send a patch.

Thanks
-- 
Oscar Salvador
SUSE L3

