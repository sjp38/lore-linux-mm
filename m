Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BBB3C10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:15:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEAF9218FC
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:15:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="fc51Dots"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEAF9218FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AEBE8E0004; Mon, 18 Feb 2019 06:15:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 837E08E0002; Mon, 18 Feb 2019 06:15:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D98F8E0004; Mon, 18 Feb 2019 06:15:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 25D888E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:15:42 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id g13so12474156plo.10
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:15:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bnsuTPZJgCfJkno9x9y084y1LYZfgF4jJqn/Ofc0v/A=;
        b=JV05MZg4ctc1Ylmhn/Pps+cSSlZfhCC9dB0dPcxTSoBUBlsHE2zYPEO00mbmXi6aLh
         7SkI+CsfBXKMxgbPFmnVbWv2QaIh4nbPSnxcVnooLRl2b5NpxtCWnk/mW7VdxvR6XjHZ
         o61wMZkjLvlykOqvlbAVTkvcnVRVqUak8uynfvoRPSByglNW9x+FRIfzsPFcE7/du7eE
         aUCieCir71QLCbMmdRHrBddBEvKqSmxoP094G8czyAHU8LehHkxmVVAqnfp+t65YTBLE
         e2TEK/dRGXDdBRSkbLvhd+o+oXHrFryRuR7sLUgXDgKoIyLb5Hq2MVrNTle8mzy7YJ9M
         eB0Q==
X-Gm-Message-State: AHQUAubi8ZYDffldS5N0aDZXLxjSAyCUampBMleXtwrfYHUFyhyD6CRx
	9/Fmg9QSV+ohwZWA+0FWsasEkbSJSW14bwI3aIbt/39cnWWYYfPyWIsTrWJ59ERZOjUAH6JV8bT
	vIMGjJe87mWEk0af/I+IvvK8rUbf7uQ13CcgYGIukRBOXolfQl+fckbwzts0/T9ZtJeYtv7AYI2
	lxyKkgC4S1+qkW1fZQp3ql/CRK0BTR5d77zd4quaRihJy7SCSkEhq9F/Ee+V5NKrOif6eb2Ro/N
	f62lApfWC5LcTkNVFhpdP2gf3f4WPv8AjuKZafPMdzLlnbU9jKgSk/73ZHn/z8nMtFRvhrLc807
	1T5RX/LRveunvs7HuG5FsEPjB3Rof64SDSC8RSiYX6i/LarGeVUoN4f7WllEdnvmYQI2I6UUmsg
	8
X-Received: by 2002:a63:788a:: with SMTP id t132mr11779619pgc.0.1550488541717;
        Mon, 18 Feb 2019 03:15:41 -0800 (PST)
X-Received: by 2002:a63:788a:: with SMTP id t132mr11779546pgc.0.1550488540720;
        Mon, 18 Feb 2019 03:15:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550488540; cv=none;
        d=google.com; s=arc-20160816;
        b=RzulBf3xSf76ivBptMyFKhlzAUFN3aTJfWkYyCOOkYTxS6jCwDVrf4m6W5TjjhZHI7
         MuNokXn2UYTI1gWZaMAZwkNKATvTGC0ua87UVB487TyfgoNACGl00wzHIGtDdXxFaT/c
         PQ7+YEvPRaScyKc9DqXZAbqObjC7WRwbAcfknox6RlYR3v0KhZkfy1A9qpurY6gCypMv
         4bvjcPSkur1J3dAY/rbSqq+7ODDrUGENE2XjkBOx8ALrwPVLfPJS8dymeF4R1FodiIT6
         +2Ajlm1ahkB754gXAlsXtwJAZvUwXVMYtCuF0TRlXPlSBXW4HYP0vtywes7h79+ovlot
         dCkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bnsuTPZJgCfJkno9x9y084y1LYZfgF4jJqn/Ofc0v/A=;
        b=AoV/PJfyRyQvBDhuL2X1ZrlSl4fSLfJDTxLFQLLZtMDQK9e4IzsluChv9NTZuraDYv
         1VnkNnmm1r/OpVMjmwUCOKPJinV/9A6tosOPBj/TNinAlQZD0LOGJy5MFlG8zlOmrh4x
         HRtGYLuqPNg3tZrPYPFb56ZH/DF4JYra0nawrEYEvPDhz/KmYmPmS7aljCB2B/g+hN4s
         ah28MyPreu/k3HutY9juMRY2RF7qrCKGkr1Hlf7eNTkxb6Grz4u1heseqK9JGR1ga4+U
         oof7/iVmsWrh6K7ub0AqeRcN+wnDTCvItIpXU8GAR+0gz6tXMXD+9dlP7nl4LujNi+ZD
         52iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=fc51Dots;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor19457996plb.63.2019.02.18.03.15.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 03:15:40 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=fc51Dots;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bnsuTPZJgCfJkno9x9y084y1LYZfgF4jJqn/Ofc0v/A=;
        b=fc51DotsSi/ZDVqcuM+zz2E5VvzsHBADPHlsTIeijFmdP1Nl4JKwpAkZ4jwpS8OUMF
         AT5Rbpqri+1WoVsMlxCvRPW7kip5cUwDzp6ApSChQJZbbYD1LSOfBW92pzlX9XnUvmrQ
         QHwUan7ORaoLdsDCo/VSVsxPdeBUKnvrcCXOJy8GhAGrtmhXbD5+rz0oPgXb0gsU9J3D
         2ZCXm+DstbvHcFbGdtkI0JE1N6YBUrGO7gKu/f5x9QcG/E2y/+cb3vMI36Rz9p9Y1GZH
         C6adDUZlg/iOx9w7cVhzlPukqD1S69Bz2C5hDr6y84DY6irCpDo+gsSzWYvX8Q3aOtzt
         soog==
X-Google-Smtp-Source: AHgI3Ia4sdyFpZDnnzf1LF4LNTSmFm3tiVnCyW0A2KoBUCySQ0q8bKhqCeNniENUIugm8eyXLQJtPA==
X-Received: by 2002:a17:902:8d8d:: with SMTP id v13mr24391965plo.121.1550488540222;
        Mon, 18 Feb 2019 03:15:40 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([134.134.139.82])
        by smtp.gmail.com with ESMTPSA id d68sm18849242pfa.64.2019.02.18.03.15.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 03:15:39 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id DA3AF3002B2; Mon, 18 Feb 2019 14:15:35 +0300 (+03)
Date: Mon, 18 Feb 2019 14:15:35 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	hughd@google.com, viro@zeniv.linux.org.uk,
	torvalds@linux-foundation.org
Subject: Re: mremap vs sysctl_max_map_count
Message-ID: <20190218111535.dxkm7w7c2edgl2lh@kshutemo-mobl1>
References: <20190218083326.xsnx7cx2lxurbmux@d104.suse.de>
 <a11a10b5-4a31-2537-7b14-83f4b22e5f6c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a11a10b5-4a31-2537-7b14-83f4b22e5f6c@suse.cz>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 10:57:18AM +0100, Vlastimil Babka wrote:
> On 2/18/19 9:33 AM, Oscar Salvador wrote:
> > 
> > Hi all,
> > 
> > I would like to bring up a topic that comes from an issue a customer of ours
> > is facing with the mremap syscall + hitting the max_map_count threshold:
> > 
> > When passing the MREMAP_FIXED flag, mremap() calls mremap_to() which does the
> > following:
> > 
> > 1) it unmaps the region where we want to put the new map:
> >    (new_addr, new_addr + new_len] [1]
> > 2) IFF old_len > new_len, it unmaps the region:
> >    (old_addr + new_len, (old_addr + new_len) + (old_len - new_len)] [2]
> > 
> > Now, having gone through steps 1) and 2), we eventually call move_vma() to do
> > the actual move.
> > 
> > move_vma() checks if we are at least 4 maps below max_map_count, otherwise
> > it bails out with -ENOMEM [3].
> > The problem is that we might have already unmapped the vma's in steps 1) and 2),
> > so it is not possible for userspace to figure out the state of the vma's after
> > it gets -ENOMEM.
> > 
> > - Did new_addr got unmaped?
> > - Did part of the old_addr got unmaped?
> > 
> > Because of that, it gets tricky for userspace to clean up properly on error
> > path.
> > 
> > While it is true that we can return -ENOMEM for more reasons
> > (e.g: see vma_to_resize()->may_expand_vm()), I think that we might be able to
> > pre-compute the number of maps that we are going add/release during the first
> > two do_munmaps(), and check whether we are 4 maps below the threshold
> > (as move_vma() does).
> > Should not be the case, we can bail out early before we unmap anything, so we
> > make sure the vma's are left untouched in case we are going to be short of maps.
> > 
> > I am not sure if that is realistically doable, or there are limitations
> > I overlooked, or we simply do not want to do that.
> 
> IMHO it makes sense to do all such resource limit checks upfront. It
> should all be protected by mmap_sem and thus stable, right? Even if it
> was racy, I'd think it's better to breach the limit a bit due to a race
> than bail out in the middle of operation. Being also resilient against
> "real" ENOMEM's due to e.g. failure to alocate a vma would be much
> harder perhaps (but maybe it's already mostly covered by the
> too-small-to-fail in page allocator), but I'd try with the artificial
> limits at least.

There's slight chance of false-postive -ENOMEM with upfront approach:
unmapping can reduce number of VMAs so in some cases upfront check would
fail something that could succeed otherwise.

We could check also what number of VMA unmap would free (if any). But it
complicates the picture and I don't think worth it in the end.

-- 
 Kirill A. Shutemov

