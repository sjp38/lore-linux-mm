Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFE37C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:02:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81B0520656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:02:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="g67/5rAM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81B0520656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C1CF6B0005; Tue,  7 May 2019 13:02:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 173CD6B0006; Tue,  7 May 2019 13:02:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A286B0007; Tue,  7 May 2019 13:02:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF5FB6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:02:10 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id u1so5255711plk.10
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:02:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=+dH1dylfToIztT6tIsED1NzXkgisvmtolImG8/gDIeU=;
        b=NN+D0udmUQ+1sk2vO2dWG3QkSi5naszuuDnm4+ysj6bE36XGYnxtMa9fr0yfBinYlr
         BsletHPB3jj+AZ68OfKGhssop6eaTqCtSV19PeVJLV7QB6nXiJWx4tlX43mgMOiXKOqB
         tAuutxxcbZex5N+Zsw4D3K7cQrNNlx9VSzqvfHpyxsdGOXAcZF3m004F931lMOrOir+a
         6rxhufaQYQyg52jrN9M24a3/26ZMrcD5sXVpKszRAhO10DeMYvn/R+VSt07xcRUWVUdW
         iNjJdaXxFNpiBZHaAtE9chuTYBKCW0wDsy/CIFdBmVDRHmZamHFmFjonRWfvXV/eCsna
         ycuw==
X-Gm-Message-State: APjAAAUiZld7ezt+zJsjnlS9Vt8BlTGqnA5LHL5BLgT7BAQT+Tlm6E1D
	zKU6UIYIdx/VhxxA3kIGxkxn8Y2MddrQkOEpH+qkBUlFo/QgGI4FuvGwM8cHTCDS+ZIMcyrhzvK
	LPy8xzH5MuUDAYnrBv/+qWk7um2yIKCGWzJ7YdZRDg8LretZ9z+aRFtm1JljUlxVlSA==
X-Received: by 2002:a63:d04b:: with SMTP id s11mr33242115pgi.187.1557248530252;
        Tue, 07 May 2019 10:02:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1pjYsNz49tYFYtJH3b28qZzeXIVbrtMsqpSuyTOK3LQHqaOwteYlyesMBM5NBn3poRC2I
X-Received: by 2002:a63:d04b:: with SMTP id s11mr33242057pgi.187.1557248529691;
        Tue, 07 May 2019 10:02:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557248529; cv=none;
        d=google.com; s=arc-20160816;
        b=lL49MPi+pYZQekk+phXqQZzo5nIGhdxPIvmwXVEbKMDV7KsktQ5q+zDs6SuGuhmpML
         sIJWrK89GoFJLNGiunFYCt21aIc2x++9F10Hj51tW9N4Led7uofZaBGLZzHFsENyzbdq
         5zzBv3IwNrODl2nvQRMHAPW9iUElbVMNjW6qqA1LZAuTZ7unEfmGCPAVjs+Rs3Q+gfOu
         kpQz53Fz0tMO9niMzy98ib94YGNNd42XcKseoc39rvN7jqRwL/ifrvIh6HvGDcQL6oyf
         WxEg/LzSMSrbtNDlpC9ei2SfyrDI9VcI2yERejfB59/xUyY2dbWs3+Wl0xRoUyDnmiVr
         Ii8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+dH1dylfToIztT6tIsED1NzXkgisvmtolImG8/gDIeU=;
        b=RZ6sMu/0Sb6HIiiLPhaUPfX+BUvS6VXa6vsMTgx3gKxi2T/PkFu8BUaiKSXHGqqgWl
         0mTBP93IkOQN8aUNXBuheSh0NIl/OBg4Vn56xExBRMb2N9kdF5s5MqPjLol9qFcGQT3m
         gfJVjaCv8TrnAYg0j+ye9NjcbwgXmFXcR3BFlZKelNqDODNnzlCI/8wW3tayrb5JzrIy
         H3X8tYLRQuwkQ/9eBb6EQ9f3fQnXOXJJlsJsPN2NOQFgyO03VjVE68jto8XoxPlmsqrc
         XOw/KqiakkL75Lba1OuzCLFu02+PI7JNfq0vDr+MUgrRCHKKE5LEPOW0V1zeRfQ23xcy
         p9mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="g67/5rAM";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a13si19179202pgh.139.2019.05.07.10.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:02:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="g67/5rAM";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3030A205C9;
	Tue,  7 May 2019 17:02:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557248529;
	bh=+dH1dylfToIztT6tIsED1NzXkgisvmtolImG8/gDIeU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=g67/5rAMyjMObT6TuHwzVVr5fhZH+BNj5IA+NG26oX7D7N4Az/RLsgF1Jc+jUk5c+
	 WAC9pINLyovaABMYNG69uAcI1Z1rL/PoxWrlPNd8yFEF2xS7eu0xqXW/90vGKpIwKR
	 2kZ9uGjgtwHlfzPHAQvgsHdgIpxzJRUuhzepGMCc=
Date: Tue, 7 May 2019 13:02:08 -0400
From: Sasha Levin <sashal@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507170208.GF1747@sasha-vm>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 09:50:50AM -0700, Linus Torvalds wrote:
>On Tue, May 7, 2019 at 9:31 AM Alexander Duyck
><alexander.duyck@gmail.com> wrote:
>>
>> Wasn't this patch reverted in Linus's tree for causing a regression on
>> some platforms? If so I'm not sure we should pull this in as a
>> candidate for stable should we, or am I missing something?
>
>Good catch. It was reverted in commit 4aa9fc2a435a ("Revert "mm,
>memory_hotplug: initialize struct pages for the full memory
>section"").
>
>We ended up with efad4e475c31 ("mm, memory_hotplug:
>is_mem_section_removable do not pass the end of a zone") instead (and
>possibly others - this was just from looking for commit messages that
>mentioned that reverted commit).

I got it wrong then. I'll fix it up and get efad4e475c31 in instead.
Thanks!

--
Thanks,
Sasha

