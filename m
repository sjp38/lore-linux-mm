Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 075326B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 04:40:28 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id gl10so3793155lab.18
        for <linux-mm@kvack.org>; Mon, 19 May 2014 01:40:27 -0700 (PDT)
Received: from mail-lb0-x232.google.com (mail-lb0-x232.google.com [2a00:1450:4010:c04::232])
        by mx.google.com with ESMTPS id tj10si7133178lbb.172.2014.05.19.01.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 01:40:26 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so3715677lbi.23
        for <linux-mm@kvack.org>; Mon, 19 May 2014 01:40:25 -0700 (PDT)
Date: Mon, 19 May 2014 12:40:22 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: mm: NULL ptr deref handling mmaping of special mappings
Message-ID: <20140519084022.GC2185@moon>
References: <5373D509.7090207@oracle.com>
 <20140514140305.7683c1c2f1e4fb0a63085a2a@linux-foundation.org>
 <5373DBE4.6030907@oracle.com>
 <20140514143124.52c598a2ba8e2539ee76558c@linux-foundation.org>
 <CALCETrXQOPBOBOgE_snjdmJM7zi34Ei8-MUA-U-YVrwubz4sOQ@mail.gmail.com>
 <20140514221140.GF28328@moon>
 <CALCETrUc2CpTEeo=NjLGxXQWHn-HG3uYUo-L3aOU-yVjVx3PGg@mail.gmail.com>
 <5374281F.6020807@parallels.com>
 <CALCETrWw7tS2Lpnb1OxgZpBwHvOSbDk2zBVtUTJEp5eooYUyhA@mail.gmail.com>
 <5379C071.4090100@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5379C071.4090100@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andy Lutomirski <luto@amacapital.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>

On Mon, May 19, 2014 at 12:27:29PM +0400, Pavel Emelyanov wrote:
> > 
> > What happens if you try to checkpoint a program that's in the vdso or,
> > worse, in a signal frame with the vdso on the stack?
> 
> Nothing good, unfortunately :( And this is one of the things we're investigating.
> Cyrill can shed more light on it, as he's the one in charge.

vdso on stack should not be a big deal, because we keep original vdso proxy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
