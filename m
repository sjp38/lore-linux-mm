Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DACA3C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:15:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86A1220645
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:15:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="hKivaIYv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86A1220645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A7908E0006; Mon, 24 Jun 2019 11:15:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 258898E0002; Mon, 24 Jun 2019 11:15:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 120E58E0006; Mon, 24 Jun 2019 11:15:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B6DF08E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:15:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d27so20917826eda.9
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tb/fwXJIPZBkB2w8y3N+xp6qDheDapQLagvbQVmWBxs=;
        b=IcrTtvOjQmdausx+M0du+C22fseXmxTht16pqfO3659tkc77I9z7GxIa9QNsG8VkRD
         ErdKxCmzhcWp/nejL2coUmkF1+ZjlV5JV5LkKPvNHcXPJrJeTLbe4+/U4FovOtlWKIiD
         vW3KXeNErFO7mToZJTbPi9MFtXWCBVfZRLN+dAyCJ2daBesn1SDfrYunpWFhzzQKFmcG
         G8mWZ5sw4SyD4PKSRroyNlpneI3iqwH5asALJeFwLakhYorszFm5qs4YTux6QGqZ/tww
         YBKwtcw8+w02jkVwTZt0TQN3Hw9lVSDOSN3Ijhk51sQWUaxJPvAYgisTkC8ouFaPBO6R
         IaUQ==
X-Gm-Message-State: APjAAAXXRbMwtwmWOObBCC83+3SURmQu79gtLEoidQNGfZ3e1B1MVxrq
	VGVzdVew0WWZllJd5VA615BEZ+gP3q8y40a2NoUkS6LEpl+w7yBZTdzKIszLt5mFCRVPMW4WdP2
	7cUaaaBYbWVOLs6rugs+taPICnFmuJ5usz1B/E4fwA8WZxxKWKuWWoropfazXct11fw==
X-Received: by 2002:a17:906:710:: with SMTP id y16mr75699358ejb.58.1561389325319;
        Mon, 24 Jun 2019 08:15:25 -0700 (PDT)
X-Received: by 2002:a17:906:710:: with SMTP id y16mr75699293ejb.58.1561389324602;
        Mon, 24 Jun 2019 08:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561389324; cv=none;
        d=google.com; s=arc-20160816;
        b=bF70GeIeoDEGo7sf1bngAyfZ2CYAUDj4Kap7WwGCPju0qiNqnWnk0mJHu62/5zSW6n
         HZ0Agjf085o93RSqK/4paeOKdWG8GSZiM0FPT0G4ILotxOmIMRSLwrmRF7FZRRlww9RS
         NJsv9QNI4+ui32cO9lYfaMpsdhKNYjXmo6vL267Dn186WuWZn8E6T8M50n/3WoZzusBV
         qw4UZz3Zt1M5Y4Lr9fU42uHLJxkPtBG+H2qraCDxBrN/MmTAZHSuzyCP7I9Sg+9w7Y/7
         6vYETHX5OBRnPP86zQ5Q1Yb76CGXsbys5X+iF0MIIE5/vLm26oQAOF3GQnRDBp/s6XEd
         nLGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tb/fwXJIPZBkB2w8y3N+xp6qDheDapQLagvbQVmWBxs=;
        b=lx0Td2MKl4K15iRVItvImNvIjJzW6S4nnX6ju/wnuojW/FO8gukUl7T2qMe71SsCkl
         HBgChyGuraqdK4jS5R0C7zRUetl5VrZQQGTLKeTMqmYfr9lT1SiOLf0tUtHgnTzZ1mgW
         FVk+ckkRNEkTJLRApfpapYltBaY9PnyWQvscbgFzwUSH4db7gQHv6brc3pmoqSdyj6lH
         d6gCgryCTS8D4gcig6QxQ48mSXqzGnWnbjz0Ch47pf1BDLFWppOk6rVi+70Ogs3nPrfV
         NDGjFraMwojJeRpOlc+6g3TEuidqnoyDRTHr7vGBiqAak2RVoOm0h6vG/c/TgKrYzDJI
         +9MA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=hKivaIYv;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z1sor2059537ejm.5.2019.06.24.08.15.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:15:24 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=hKivaIYv;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=tb/fwXJIPZBkB2w8y3N+xp6qDheDapQLagvbQVmWBxs=;
        b=hKivaIYvCcbw0ygV6Kz/ud/MoCDO10N8kdFBEYqhIMh4ZVCmzkU5sNxig8oy6ZYXyO
         DaxcwQ0dkrrDxCs+vYrQatvN8v7AZbUi+4VwFuHZnNzOD1wtZ8Y54yY17uaAJEGQ6PcN
         yRxIyk/1RryQNYcrfRh4XEPNBhwjPu1A6L+5MulFzYjeDc/0xxkYjzHAmbGMJ5NKWyA9
         UkUGsfw18XOL+7K9WbelemLiJ3LthA+M0veyhFrPVt6CR8IQFI15s1KBKIOSa3dsDjT8
         uBxf4Mz5ND81hGRaKlV6YbyHwMOiqyw7I9U54xVYEi2z/yawXzgiyOpuhmO7EF3adB03
         IU2w==
X-Google-Smtp-Source: APXvYqz2rk4utKNukeyBdZl2ORALqkVcwVPb1q4qGRLCaAP8B6P/6LhMQuSx+7vkAKVkB7JktYIaZQ==
X-Received: by 2002:a17:906:85d4:: with SMTP id i20mr20687001ejy.256.1561389324273;
        Mon, 24 Jun 2019 08:15:24 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id f2sm873444ejb.41.2019.06.24.08.15.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 08:15:23 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id A98AF1043B3; Mon, 24 Jun 2019 18:15:28 +0300 (+03)
Date: Mon, 24 Jun 2019 18:15:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hdanton@sina.com" <hdanton@sina.com>
Subject: Re: [PATCH v7 5/6] mm,thp: add read-only THP support for (non-shmem)
 FS
Message-ID: <20190624151528.fnz3hvlnyvea3ytn@box>
References: <20190623054749.4016638-1-songliubraving@fb.com>
 <20190623054749.4016638-6-songliubraving@fb.com>
 <20190624124746.7evd2hmbn3qg3tfs@box>
 <52BDA50B-7CBF-4333-9D15-0C17FD04F6ED@fb.com>
 <20190624142747.chy5s3nendxktm3l@box>
 <C3161C66-5044-44E6-92F4-BBAD42EDF4E2@fb.com>
 <20190624145453.u4ej3e4ktyyqjite@box>
 <5BE23F34-B611-496B-9277-A09C9CC784B1@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5BE23F34-B611-496B-9277-A09C9CC784B1@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 03:04:21PM +0000, Song Liu wrote:
> 
> 
> > On Jun 24, 2019, at 7:54 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > 
> > On Mon, Jun 24, 2019 at 02:42:13PM +0000, Song Liu wrote:
> >> 
> >> 
> >>> On Jun 24, 2019, at 7:27 AM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> >>> 
> >>> On Mon, Jun 24, 2019 at 02:01:05PM +0000, Song Liu wrote:
> >>>>>> @@ -1392,6 +1403,23 @@ static void collapse_file(struct mm_struct *mm,
> >>>>>> 				result = SCAN_FAIL;
> >>>>>> 				goto xa_unlocked;
> >>>>>> 			}
> >>>>>> +		} else if (!page || xa_is_value(page)) {
> >>>>>> +			xas_unlock_irq(&xas);
> >>>>>> +			page_cache_sync_readahead(mapping, &file->f_ra, file,
> >>>>>> +						  index, PAGE_SIZE);
> >>>>>> +			lru_add_drain();
> >>>>> 
> >>>>> Why?
> >>>> 
> >>>> isolate_lru_page() is likely to fail if we don't drain the pagevecs. 
> >>> 
> >>> Please add a comment.
> >> 
> >> Will do. 
> >> 
> >>> 
> >>>>>> +			page = find_lock_page(mapping, index);
> >>>>>> +			if (unlikely(page == NULL)) {
> >>>>>> +				result = SCAN_FAIL;
> >>>>>> +				goto xa_unlocked;
> >>>>>> +			}
> >>>>>> +		} else if (!PageUptodate(page)) {
> >>>>> 
> >>>>> Maybe we should try wait_on_page_locked() here before give up?
> >>>> 
> >>>> Are you referring to the "if (!PageUptodate(page))" case? 
> >>> 
> >>> Yes.
> >> 
> >> I think this case happens when another thread is reading the page in. 
> >> I could not think of a way to trigger this condition for testing. 
> >> 
> >> On the other hand, with current logic, we will retry the page on the 
> >> next scan, so I guess this is OK. 
> > 
> > What I meant that calling wait_on_page_locked() on !PageUptodate() page
> > will likely make it up-to-date and we don't need to SCAN_FAIL the attempt.
> > 
> 
> Yeah, I got the point. My only concern is that I don't know how to 
> reliably trigger this case for testing. I can try to trigger it. But I 
> don't know whether it will happen easily. 

Atrifically slowing down IO should do the trick.

-- 
 Kirill A. Shutemov

