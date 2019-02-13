Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA0CDC282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59E7D222BB
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 02:13:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59E7D222BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6B0F8E0002; Tue, 12 Feb 2019 21:13:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1A6E8E0001; Tue, 12 Feb 2019 21:13:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D32258E0002; Tue, 12 Feb 2019 21:13:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 903278E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 21:13:23 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a10so608799plp.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 18:13:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=r4V97l6XPsCekyE6ibxz539cJGfMM0efGv8qH0rh0Tk=;
        b=hpQu0kNSxyrDK52DnrKCxY8GZlL7CigAcdjmEkl4eLEZzX9weFv4bqYc8rWroaRn46
         iFPTchZTftIiNp0g7tUdgML+PM2EpQihZARdlnkCXWRvMSfuFyEaISXEN5vtLD7E0swt
         0fmNCZOl6F0nkCQbWuABiZWVenmOyznZ0Mf7tzK8iA8sDz8V+9N6yzthgrRQh+o+sYne
         WTOrT4iy0HGmWb+1HBRbLdz2yqOMXCX5/kkFmrwp6oQWpqdv5haEAT2uuVb8ZRp0wsl5
         M/NjIuYbcwTp2SQCUil/Q9jKGOTppglKwL2mGc7uVtZoyLXgDYwicnt7vonaZCSC36+i
         0TlQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZbwpewMnzPqD3bWttOGBNYoyNZ0F2eEZlwBy9ECH/f6SGaTMxZ
	4a5LydBC141AbJ6HNeh/mNGTnch0c+M84HoNZTHgMZH13kCXSQbzF8fiI55s0BBx2q/ofn/l4Cs
	9RKycIwmfr2XKebcb0JQINUO6phZgwd88ReQ79EUsCf8aJWehcqLUeZNHzFGVx7c=
X-Received: by 2002:a63:5107:: with SMTP id f7mr6300167pgb.218.1550024003139;
        Tue, 12 Feb 2019 18:13:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZK3V5jRlwsfoIODb11fYmr81jWZN8iFDODLVUOxVN0As709FE0lmiJqWTtuEYf6MPRpY6p
X-Received: by 2002:a63:5107:: with SMTP id f7mr6300108pgb.218.1550024002184;
        Tue, 12 Feb 2019 18:13:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550024002; cv=none;
        d=google.com; s=arc-20160816;
        b=ToqjQPjvZd8LFJN85UrpjAB8Rsq4a899Ix3Ofm7HBprzuPnwzzt5muLNGAfvrXxqaT
         hOHxjEFFu2AcVUWKz53p0/UINdmhVVowF3HbvCEzkGJWgDUNkLU6LRmuUQyPKwrW26Pi
         IrsKRaYQOCQXw0RSP6uQthNqysaqsHh11BoHgiFdWbq2HZjzywMmASlcq6yEezpogKwH
         586qBrctD7WEBU12QtyGhdKyKUt32Dioe8UCJ1qw4AQt68ipnozVYmBckZ4TywKt3DQ0
         7zm44xpoM7JEjOt65kBAvd/6EUeSmksTjLLrqBDt9pEXKEH0aPeqNot8kLrbOPh4lkgN
         qV0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=r4V97l6XPsCekyE6ibxz539cJGfMM0efGv8qH0rh0Tk=;
        b=CMVxUSLu1uVG5qtF6QhFmLWWuTkAQUFmPMOAmetUUt4FZnoQuCxHD6G76n16nnySxb
         Hb42IfZZD4x8RXD7rGd1EVL3K5vCnojzTPTdvRam38WW875og9EJbiz6M4AJOHVUETQg
         9B8fmraoZ2ovgkmZu7r42rMWy1Fnh+vX52lmLccJTV2poutEBX6ejKVndhcHmzKg4zKx
         BtYI4JF9O9EB6eC3mhj5tVy7L/k6c0G0l+DdxBag0V3Xcb4QR5TnrYh6YkYXRYP1Iv4Z
         VqTS6g4POs0cx3ApJrCzfHI1PEg4kfhRzWq9zR+ogUQoMM4Yj4ttr7J4DofJl93FxfEx
         Ge0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id i13si7294991pgj.199.2019.02.12.18.13.21
        for <linux-mm@kvack.org>;
        Tue, 12 Feb 2019 18:13:22 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 13 Feb 2019 12:43:19 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gtk34-00040r-GL; Wed, 13 Feb 2019 13:13:18 +1100
Date: Wed, 13 Feb 2019 13:13:18 +1100
From: Dave Chinner <david@fromorbit.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	"Shutemov, Kirill" <kirill.shutemov@intel.com>,
	"Schofield, Alison" <alison.schofield@intel.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
Message-ID: <20190213021318.GN20493@dastard>
References: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
 <20190212235114.GM20493@dastard>
 <CAPcyv4jhbYfrdTOyh90-u-gEUV7QEgF_HrNid5w5WbPPGr=axw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4jhbYfrdTOyh90-u-gEUV7QEgF_HrNid5w5WbPPGr=axw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 04:27:20PM -0800, Dan Williams wrote:
> On Tue, Feb 12, 2019 at 3:51 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Tue, Feb 12, 2019 at 08:55:57AM -0800, Dave Hansen wrote:
> > > Multi-Key Total Memory Encryption (MKTME) [1] is feature of a memory
> > > controller that allows memory to be selectively encrypted with
> > > user-controlled key, in hardware, at a very low runtime cost.  However,
> > > it is implemented using AES-XTS which encrypts each block with a key
> > > that is generated based on the physical address of the data being
> > > encrypted.  This has nice security properties, making some replay and
> > > substitution attacks harder, but it means that encrypted data can not be
> > > naively relocated.
> >
> > The subject is "Memory Encryption on top of filesystems", but really
> > what you are talking about is "physical memory encryption /below/
> > filesystems".
> >
> > i.e. it's encryption of the physical storage the filesystem manages,
> > not encryption within the fileystem (like fscrypt) or or user data
> > on top of the filesystem (ecryptfs or userspace).
> >
> > > Combined with persistent memory, MKTME allows data to be unlocked at the
> > > device (DIMM or namespace) level, but left encrypted until it actually
> > > needs to be used.
> >
> > This sounds more like full disk encryption (either in the IO
> > path software by dm-crypt or in hardware itself), where the contents
> > are decrypted/encrypted in the IO path as the data is moved between
> > physical storage and the filesystem's memory (page/buffer caches).
> >
> > Is there any finer granularity than a DIMM or pmem namespace for
> > specifying encrypted regions? Note that filesystems are not aware of
> > the physical layout of the memory address space (i.e. what DIMM
> > corresponds to which sector in the block device), so DIMM-level
> > granularity doesn't seem particularly useful right now....
> >
> > Also, how many different hardware encryption keys are available for
> > use, and how many separate memory regions can a single key have
> > associated with it?
> >
> > > However, if encrypted data were placed on a
> > > filesystem, it might be in its encrypted state for long periods of time
> > > and could not be moved by the filesystem during that time.
> >
> > I'm not sure what you mean by "if encrypted data were placed on a
> > filesystem", given that the memory encryption is transparent to the
> > filesystem (i.e. happens in the memory controller on it's way
> > to/from the physical storage).
> >
> > > The “easy” solution to this is to just require that the encryption key
> > > be present and programmed into the memory controller before data is
> > > moved.  However, this means that filesystems would need to know when a
> > > given block has been encrypted and can not be moved.
> >
> > I'm missing something here - how does the filesystem even get
> > mounted if we haven't unlocked the device the filesystem is stored
> > on? i.e. we need to unlock the entire memory region containing the
> > filesystem so it can read and write it's metadata (which can be
> > randomly spread all over the block device).
> >
> > And if we have to do that to mount the filesystem, then aren't we
> > also unlocking all the same memory regions that contain user data
> > and hence they can be moved?
> 
> Yes, and this is the most likely scenario for enabling MKTME with
> persistent memory. The filesystem will not be able to mount until the
> entire physical address range (namespace device) is unlocked, and the
> filesystem is kept unaware of the encryption. One key per namespace
> device.
> 
> > At what point do we end up with a filesystem mounted and trying to
> > access a locked memory region?
> 
> Another option is to enable encryption to be specified at mmap time
> with the motivation of being able to use the file system for
> provisioning instead of managing multiple namespaces.

I'm assuming you are talking about DAX here, yes?

Because fscrypt....

> The filesystem
> would need to be careful to use the key for any physical block
> management, and a decision would need to be made about when/whether
> read(2)/write(2) access cipher text .

... already handles all this via page cache coherency for
mmap/read/write IO.

> The current thinking is that
> this would be too invasive / restrictive for the filesystem, but it's
> otherwise an interesting thought experiment for allowing the
> filesystem to take on more physical-storage allocation
> responsibilities.

Actually what we want in the filesystem world is /hardware offload/
abstractions in the filesystems, not "filesystem controls hardware
specific physical storage features" mechanisms.

i.e. if the filesystem/fscrypt can offload the encryption of the
data to the IO path by passing the fscrypt key/info with the IO,
then it works with everything, not just pmem.

In the case of pmem+DAX+mmap(), it needs to associate the correct
key with the memory region that is to be encrypted when it is
mmap()d. Then the DAX subsystem can associate the key with the
physical pages that are faulted during DAX access. If it's bio based
IO going to the DAX driver, then the keys should be attached to the
bio....

fscrypt encrypt/decrypt is already done at the filesystem/bio
interface layer via bounce buffers - it's not a great stretch to
push this down a layer so that it can be offloaded to the underlying
device if it is hardware encryption capable. fscrypt would really
only be used for key management (like needs work to support
arbitrary hardware keys) and in filesystem metadata encryption (e.g.
filenames) in that case....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

