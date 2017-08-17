Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 98DC76B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 23:31:52 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id g129so88318639ywh.11
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 20:31:52 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id g21si643415ybe.541.2017.08.16.20.31.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 20:31:51 -0700 (PDT)
Date: Wed, 16 Aug 2017 23:31:48 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCHv3 2/2] extract early boot entropy from the passed cmdline
Message-ID: <20170817033148.ownsmbdzk2vhupme@thunk.org>
References: <20170816231458.2299-1-labbott@redhat.com>
 <20170816231458.2299-3-labbott@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816231458.2299-3-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, Daniel Micay <danielmicay@gmail.com>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, Aug 16, 2017 at 04:14:58PM -0700, Laura Abbott wrote:
> From: Daniel Micay <danielmicay@gmail.com>
> 
> Existing Android bootloaders usually pass data useful as early entropy
> on the kernel command-line. It may also be the case on other embedded
> systems.....

May I suggest a slight adjustment to the beginning commit description?

   Feed the boot command-line as to the /dev/random entropy pool

   Existing Android bootloaders usually pass data which may not be
   known by an external attacker on the kernel command-line.  It may
   also be the case on other embedded systems.  Sample command-line
   from a Google Pixel running CopperheadOS....

The idea here is to if anything, err on the side of under-promising
the amount of security we can guarantee that this technique will
provide.  For example, how hard is it really for an attacker who has
an APK installed locally to get the device serial number?  Or the OS
version?  And how much variability is there in the bootloader stages
in milliseconds?

I think we should definitely do this.  So this is more of a request to
be very careful what we promise in the commit description, not an
objection to the change itself.

Cheers,

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
