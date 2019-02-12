Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F3A1C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:41:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA5262077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 09:41:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="oz4fqcyB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA5262077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6592D8E0018; Tue, 12 Feb 2019 04:41:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E0238E0017; Tue, 12 Feb 2019 04:41:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 481D88E0018; Tue, 12 Feb 2019 04:41:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0578A8E0017
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 04:41:55 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y8so1692614pgq.12
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:41:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ULKJGWPq0No+6GC/bcxSVWYWrbcjwzSVvmdDBR8FNpg=;
        b=XBTxHEkXQWpevudTzyVqGuBuNa7wbCvLDNMSuHd6t1dmCRGEwiJu7zZQYRWsxX77iK
         e7iEPNqfcHhEwok3uz64UqQlNHBsSpoWF4ggnLZ+R9K8K6noorVTcuJoXlyhxJzkKhY2
         5nPpNHFaWTFLNGhc2oo8OjB92MPKFcuPEqEt+fdLrwGhKXWbk94OGSDRNvZUWq0c7wkH
         hv+JUtH8mb6FnqkI5x4VzvaQivgqbMNEhQZ+mHhp5W/ExNN3jq73GNBEeyJy9aa05zBC
         JcOOwS6Yb9f8WAxpA+gc7+VlBdu0eCpJuvThpcV96JE6myw6CgC8CZwRIC81rX4eX0hn
         j56Q==
X-Gm-Message-State: AHQUAuaDAlBD/ghLKofjg8eC1isXkRHlsFwxjBLi/xwpxUKV7ceKgBVL
	enIV27qE0m/C/9G8yFI5a5Q4hd4LP1aJ+LMjlauCjikGpXuOGCmVOskvTsxZNo5FdCPI/a1+niW
	1jU4sv2BbLIQ6ji+gIfi/xaa8FBy4Uv/KU5Ee35/uqeDJzIgjw2anRYwrPc4uFARoN05yOlcha4
	h4t74zpf7ePlaRlcFaqOGu/x2kIFY1URiPZxRv45m+099R69ha4o1ZWquDqZ7aoFOlAHskHe8qV
	tnEFNPOwhDZT91XTdQNp8Gxy09+eqAe1tYeTrM4PsRdXEJop/UYIGM0rVaTe2sA878Q1o8WsHxe
	ZmE+Q6deDs5B9CifgiyzT7ygBz8zgYc69nCH1NmSuaqODfhTWu9kuB55ZzzU7Wj27UuJ5vCp1L7
	G
X-Received: by 2002:a63:fa10:: with SMTP id y16mr2767121pgh.88.1549964514550;
        Tue, 12 Feb 2019 01:41:54 -0800 (PST)
X-Received: by 2002:a63:fa10:: with SMTP id y16mr2767076pgh.88.1549964513624;
        Tue, 12 Feb 2019 01:41:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549964513; cv=none;
        d=google.com; s=arc-20160816;
        b=r057nd0iIgDKy2uuEi8cRrWhVKXEgHAHTAeZ6BzTzztiUHkb1whm3GXPwgGRw1Oy23
         VzvRPG6d5TmdnYKOMVlURH2qws6eKijTd+9pAMNlxV2BIGvkvhpYaISQKyGt17Yjv2Ce
         2n1SPHBUSFC/l4cgzsIpzv4KFTB3Be0t+wh05lD6KkzKO30M1frszjsxtQowSpW2gi93
         A0pjylb5MLQWPdGMSukTPdwqDbIz929vVFi7JV6ZiMZbUWK+7ugpvvk4a2b4sNloHIXA
         LuSUal/0+rnIZAFKlMQffrv5c0sr+7XEHlIeQ0FknVPmKiLQwM8Qp3Ij+gq3Ohv/Io8/
         dWIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ULKJGWPq0No+6GC/bcxSVWYWrbcjwzSVvmdDBR8FNpg=;
        b=Hto2x4yDmi8ezKU0sOwp0g2ltN/BMYqj7X+ROmeT24Fq5UWeZ3jbcxlXBBo6qH1DAl
         3NPF28i2bJEBklM6z1rJk3BgRi4ukZieMj1TtnXkMypXE89nZYd5cDgbrR03o84/GV0Q
         UJDcPHkUSrzYrKmdUODOdvuYtEo2tCuStLUPy/GVbsjo4zn+LGvOAVExxrcPWp0edIWW
         H/yOupIoI+rPvJ3Hu7+XR4FR+eYWpXLobu73DFjy6JyYR9tsjSc0qmvi/T63L7hSdCRL
         7Z+6/kMkmPLGj5VuD03F01oqn5BoDvJ1cH9zvuyWxfFumzaivjPTRj9ERvxJuhxejGm/
         9mrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=oz4fqcyB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b1sor18207438plx.42.2019.02.12.01.41.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 01:41:53 -0800 (PST)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=oz4fqcyB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ULKJGWPq0No+6GC/bcxSVWYWrbcjwzSVvmdDBR8FNpg=;
        b=oz4fqcyBSi9ismZ7bytPCCn4QB2ehAPOo+jJuLzFVX2NYQ2azlwSYNQBmERfG1ZuVw
         eGQZGM7lEK7RcBM76vfU85SEtWwdtfVlExo96dNE435NP4TRW+crgtzDnNLH2uiShe2D
         CwsP6ZtNLwtB1FlDIIQbLv9+FEtcXyO4hy+6FZNg87BGUV0zDhttBb5qxe4RGMjCgAuE
         lEQH00osnCynrZmPPIePFjLqDylh8H7cpz8tzII/yALTiUwRjYgKyvDa5VgsfPyedIw0
         IVDExWw/9JzIlSmvGEQ8UnoP8VqC513UTVg+F0p3R9/36fwKNNdRIFjXXWxuZfv3840I
         ulyA==
X-Google-Smtp-Source: AHgI3IZbSkcUnItYKRqYqpDbDeAVRnQeTmuDwZZXQAMV8eQDd3Fni7xJYWoe03xeFvKMmhVcwLOcvA==
X-Received: by 2002:a17:902:bd0b:: with SMTP id p11mr3085458pls.259.1549964512626;
        Tue, 12 Feb 2019 01:41:52 -0800 (PST)
Received: from kshutemo-mobl1.localdomain ([192.55.54.44])
        by smtp.gmail.com with ESMTPSA id y21sm17816378pfi.150.2019.02.12.01.41.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 01:41:52 -0800 (PST)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 84BA1300100; Tue, 12 Feb 2019 12:41:48 +0300 (+03)
Date: Tue, 12 Feb 2019 12:41:48 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Jann Horn <jannh@google.com>
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-mm@kvack.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Hansen <dave.hansen@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linuxppc-dev@lists.ozlabs.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-api@vger.kernel.org
Subject: Re: [PATCH] mmap.2: describe the 5level paging hack
Message-ID: <20190212094148.qpd6wudyry5vzw3v@kshutemo-mobl1>
References: <20190211163653.97742-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211163653.97742-1-jannh@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 05:36:53PM +0100, Jann Horn wrote:
> The manpage is missing information about the compatibility hack for
> 5-level paging that went in in 4.14, around commit ee00f4a32a76 ("x86/mm:
> Allow userspace have mappings above 47-bit"). Add some information about
> that.
> 
> While I don't think any hardware supporting this is shipping yet (?), I
> think it's useful to try to write a manpage for this API, partly to
> figure out how usable that API actually is, and partly because when this
> hardware does ship, it'd be nice if distro manpages had information about
> how to use it.
> 
> Signed-off-by: Jann Horn <jannh@google.com>

Thanks for doing this.

> ---
> This patch goes on top of the patch "[PATCH] mmap.2: fix description of
> treatment of the hint" that I just sent, but I'm not sending them in a
> series because I want the first one to go in, and I think this one might
> be a bit more controversial.
> 
> It would be nice if the architecture maintainers and mm folks could have
> a look at this and check that what I wrote is right - I only looked at
> the source for this, I haven't tried it.
> 
>  man2/mmap.2 | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 8556bbfeb..977782fa8 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -67,6 +67,8 @@ is NULL,
>  then the kernel chooses the (page-aligned) address
>  at which to create the mapping;
>  this is the most portable method of creating a new mapping.
> +On Linux, in this case, the kernel may limit the maximum address that can be
> +used for allocations to a legacy limit for compatibility reasons.
>  If
>  .I addr
>  is not NULL,
> @@ -77,6 +79,19 @@ or equal to the value specified by
>  and attempt to create the mapping there.
>  If another mapping already exists there, the kernel picks a new
>  address, independent of the hint.
> +However, if a hint above the architecture's legacy address limit is provided
> +(on x86-64: above 0x7ffffffff000, on arm64: above 0x1000000000000, on ppc64 with
> +book3s: above 0x7fffffffffff or 0x3fffffffffff, depending on page size), the
> +kernel is permitted to allocate mappings beyond the architecture's legacy
> +address limit. The availability of such addresses is hardware-dependent.
> +Therefore, if you want to be able to use the full virtual address space of
> +hardware that supports addresses beyond the legacy range, you need to specify an
> +address above that limit; however, for security reasons, you should avoid
> +specifying a fixed valid address outside the compatibility range,
> +since that would reduce the value of userspace address space layout
> +randomization. Therefore, it is recommended to specify an address
> +.I beyond
> +the end of the userspace address space.

It probably worth recommending (void *) -1 as such address.

>  .\" Before Linux 2.6.24, the address was rounded up to the next page
>  .\" boundary; since 2.6.24, it is rounded down!
>  The address of the new mapping is returned as the result of the call.
> -- 
> 2.20.1.791.gb4d0f1c61a-goog
> 

-- 
 Kirill A. Shutemov

