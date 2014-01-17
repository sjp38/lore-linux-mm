Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f182.google.com (mail-vc0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id 88DAC6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 19:57:12 -0500 (EST)
Received: by mail-vc0-f182.google.com with SMTP id id10so1273175vcb.41
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:57:12 -0800 (PST)
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
        by mx.google.com with ESMTPS id us10si4055372vcb.59.2014.01.16.16.57.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Jan 2014 16:57:11 -0800 (PST)
Received: by mail-ve0-f173.google.com with SMTP id oz11so150976veb.4
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 16:57:11 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 16 Jan 2014 16:56:50 -0800
Message-ID: <CALCETrUaotUuzn60-bSt1oUb8+94do2QgiCq_TXhqEHj79DePQ@mail.gmail.com>
Subject: [LSF/MM TOPIC] [ATTEND] Persistent memory
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

I'm interested in a persistent memory track.  There seems to be plenty
of other emails about this, but here's my take:

First, I'm not an FS expert.  I've never written an FS, touched an
on-disk (or on-persistent-memory) FS format.  I have, however, mucked
with some low-level x86 details, and I'm a heavy abuser of the Linux
page cache.

I'm an upcoming user of persistent memory -- I have some (in the form
if NV-DIMMs) and I have an application (HFT and a memory-backed
database thing) that I'll port to run on pmfs or ext4 w/ XIP once
everything is ready.

I'm also interested in some of the implementation details.  For this
stuff to be reliable on anything resembling commodity hardware, there
will be some caching issues to deal with.  For example, I think it
would be handy to run things like pmfs on top of write-through
mappings.  This is currently barely supportable (and only using
mtrrs), but it's not terribly complicated (on new enough hardware) to
support real write-through PAT entries.

I've written an i2c-imc driver (currently in limbo on the i2c list),
which will likely be used for control operations on NV-DIMMs plugged
into Intel-based server boards.

In principle, I could even bring a working NV-DIMM system to the
summit -- it's nearby, and this thing isn't *that* large :)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
