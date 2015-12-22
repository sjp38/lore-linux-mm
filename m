Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 644886B0262
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:28:50 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id jx14so92438060pad.2
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:28:50 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id h78si13311762pfd.42.2015.12.22.09.28.49
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 09:28:49 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-7-git-send-email-laura@labbott.name>
 <567964F3.2020402@intel.com>
 <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org>
 <567986E7.50107@intel.com>
 <alpine.DEB.2.20.1512221124230.14335@east.gentwo.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56798851.60906@intel.com>
Date: Tue, 22 Dec 2015 09:28:49 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1512221124230.14335@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On 12/22/2015 09:24 AM, Christoph Lameter wrote:
> On Tue, 22 Dec 2015, Dave Hansen wrote:
>> Or are you just saying that we should use the poisoning *code* that we
>> already have in slub?  Using the _code_ looks like a really good idea,
>> whether we're using it to write POISON_FREE, or 0's.  Something like the
>> attached patch?
> 
> Why would you use zeros? The point is just to clear the information right?
> The regular poisoning does that.

It then allows you to avoid the zeroing at allocation time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
