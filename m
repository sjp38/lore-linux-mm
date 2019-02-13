Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBB85C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:31:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D8EC21904
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:31:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qnhqPE73"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D8EC21904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30DE58E0002; Tue, 12 Feb 2019 22:31:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BCA68E0001; Tue, 12 Feb 2019 22:31:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ACD18E0002; Tue, 12 Feb 2019 22:31:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0EE48E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 22:31:50 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id j23so917605otl.6
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:31:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=KF0zgxPuyMfvXHcwMoxObnPHMJ+VQQ4AjaJw9kOiNvo=;
        b=NYoPOp9r2IScH3dOq2bq9HJ2rCRy3tc7pbMiWnChG//dYxXVeVYuIuptxf+vT5Isi/
         e0QDMXQ7T/X/Q0Onk/Xid6DoU39wyxm2/M+IvP4DSvKM26IxApd8eCgdFQdGSZddDA77
         DULzyAtVyEHN/rp9Lo/efn21eug2qQawABvHYyRPEjbzgKwdiL/kQ/3A0GaicdwMWyZz
         IxETK8L76zUCXmUBgH9QDDfd1jS8+dI9cFSG5cJOtCBaNGTmSnh4lPFyozOVdAWQRgf3
         m6bJLTLSiyEjGeBWaxb+Pq4VvE8MJdIPar9zEZQ6CPrMgjXM1aLoPzzpbA6SW07T7eJl
         jvuA==
X-Gm-Message-State: AHQUAubBWgDjFn5PV5cn1leGn3BB2IG3WGBiVIZunponl3uDKUcR2913
	XdEU3iDBAhLdfXYUffuEXXhHcw4mFoI/B+2+TmuYZDZ7gn05n5040rb/gSv3sS4e2JGb275grlC
	pe94cEToK4gmEcyx+aCbXIZiugfDCII/Y3dzFcc7qhEe+18jDZXzmRWZEhwijnmYDrZCo3FQLrC
	iycCPazgvFXRF0YOl+3LMUDQRwN+y3agVv8NR5gt7c6qHpAWsivvRuQ6Hu5RCVSDEHJZY2A2JD9
	WmVtsmZd/zZUPxvYxXONoyBPnLpzaCybjFKVIf8RjQKa+ebg7P/R8KKKvqU11NlyV3QOvmG2bvT
	32h2Q2douZcsTYjU9WhXtSdfCTU4mmJjWDbY2cUpxkxBheuJggXoIVkuNrqcIozAwtHZR0PP3Rg
	+
X-Received: by 2002:a9d:4d8b:: with SMTP id u11mr7328798otk.60.1550028710557;
        Tue, 12 Feb 2019 19:31:50 -0800 (PST)
X-Received: by 2002:a9d:4d8b:: with SMTP id u11mr7328750otk.60.1550028709695;
        Tue, 12 Feb 2019 19:31:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550028709; cv=none;
        d=google.com; s=arc-20160816;
        b=i2jCbAi2w2fbMiVdMYieJGSWS/dE9rRKtf0H5y0jLmgjyuDP/fCi0OyxI9tl0XOHlA
         KxmmOrPY249K6GE2ZG78NiDr9LXq9BpNMBS4VZpZlZVi3y70YZzewFxuxfxb6oTV+Em5
         kRE0IuCOCHj9EISE96JXAO/x5tZq6WW63Fd2gYHMCtR9iQQgpP4ZvQRQ614f1VEgXqLe
         PcDbhzD9zm+Me6pgEf8KIBU5dVn4jfx2WZLXooJ2yjgkMaKfZmrc91n5T/SNwA+sZNPh
         mBff6JsKW3k2dCOKkYKqZiH7KI55ECO/ZQwiS+1waBbYNr2qoXKpgTsVn1ZWwoPyg4Ou
         tOAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=KF0zgxPuyMfvXHcwMoxObnPHMJ+VQQ4AjaJw9kOiNvo=;
        b=L5ed4uAgTbCwMJBuT1FRdh/ntnbTNlIJpSSw0iEkAXDZ0F/kedW1ylVTMTeVTdUu4l
         tqtfsysbbZMIJ5AXIdeAESHY+Its9bcngUNeg+12jFj95KkK0H5gYZ5gmhqlFwWnKbVr
         AZRKSC+H4qKCMbyeUt/N8pZOy15m2XB6KEyac61lbWkKHcBkR1B2LAxR97f8BaUe2m4f
         mPDkEtg5Xd+uWpzZUAiP6NhOK57dOXsOEgmOmspwjLWEoq1rtt22L6CXRLALhnXhQcNh
         LDmxeTK7M8VCKo6Z0KpP38gisOEO4ZMYke2+7iF1WqGLngae/QH09wJjeotYkWpWPmVg
         tE5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qnhqPE73;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11sor10503794otp.183.2019.02.12.19.31.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 19:31:49 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qnhqPE73;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=KF0zgxPuyMfvXHcwMoxObnPHMJ+VQQ4AjaJw9kOiNvo=;
        b=qnhqPE73D7EKnK3xRjX5Zvl3kTQQOQ7AvYA7A4VwPEojwx7pApENepji5qc/kYGtac
         TaX1JCg0KIHCIvkCJusreXXtGZbf4KhirV7Jf+7Q2Rb+Eb1rVUg7euNaUp8lFh6qPMQN
         lsS/WSJWxu91IOaylEOibK+wU0L/RtnlffWt0p/c8nNTnk1bmgtMnWPgo2LR4HFaepYy
         8dPOrM08opIDn1NhKEL+085jvE6b8+daq7Q9cdK5MTR3WdrffcSmB0yfXftY/vO6Cmoe
         dqtTcM0pmaA4j9QFqfw05vEa08iX1zWTe7PoYb+r1eIRj1iowa6IdQ5WH8aX8yIw4Cln
         vtLw==
X-Google-Smtp-Source: AHgI3IartJHr+9QAjB9CRlG6y5nAhyfRmv+egqVU7TNj+GngkKufiwO8grNqF5RgvoZplRr3gUShKkiB/1F8bmHWd4Q=
X-Received: by 2002:a9d:7493:: with SMTP id t19mr6850371otk.98.1550028708919;
 Tue, 12 Feb 2019 19:31:48 -0800 (PST)
MIME-Version: 1.0
References: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
 <20190212235114.GM20493@dastard> <CAPcyv4jhbYfrdTOyh90-u-gEUV7QEgF_HrNid5w5WbPPGr=axw@mail.gmail.com>
 <20190213021318.GN20493@dastard>
In-Reply-To: <20190213021318.GN20493@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Feb 2019 19:31:37 -0800
Message-ID: <CAPcyv4g4vF84Ufrdv8ocwfW3hrvUJ_GaF65AbZyXzaZJQVMjEw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
To: Dave Chinner <david@fromorbit.com>
Cc: Dave Hansen <dave.hansen@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	"Shutemov, Kirill" <kirill.shutemov@intel.com>, 
	"Schofield, Alison" <alison.schofield@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, 
	Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>, 
	Jaegeuk Kim <jaegeuk@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Ted and Jaegeuk ]

On Tue, Feb 12, 2019 at 6:14 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Tue, Feb 12, 2019 at 04:27:20PM -0800, Dan Williams wrote:
> > On Tue, Feb 12, 2019 at 3:51 PM Dave Chinner <david@fromorbit.com> wrot=
e:
> > >
> > > On Tue, Feb 12, 2019 at 08:55:57AM -0800, Dave Hansen wrote:
> > > > Multi-Key Total Memory Encryption (MKTME) [1] is feature of a memor=
y
> > > > controller that allows memory to be selectively encrypted with
> > > > user-controlled key, in hardware, at a very low runtime cost.  Howe=
ver,
> > > > it is implemented using AES-XTS which encrypts each block with a ke=
y
> > > > that is generated based on the physical address of the data being
> > > > encrypted.  This has nice security properties, making some replay a=
nd
> > > > substitution attacks harder, but it means that encrypted data can n=
ot be
> > > > naively relocated.
> > >
> > > The subject is "Memory Encryption on top of filesystems", but really
> > > what you are talking about is "physical memory encryption /below/
> > > filesystems".
> > >
> > > i.e. it's encryption of the physical storage the filesystem manages,
> > > not encryption within the fileystem (like fscrypt) or or user data
> > > on top of the filesystem (ecryptfs or userspace).
> > >
> > > > Combined with persistent memory, MKTME allows data to be unlocked a=
t the
> > > > device (DIMM or namespace) level, but left encrypted until it actua=
lly
> > > > needs to be used.
> > >
> > > This sounds more like full disk encryption (either in the IO
> > > path software by dm-crypt or in hardware itself), where the contents
> > > are decrypted/encrypted in the IO path as the data is moved between
> > > physical storage and the filesystem's memory (page/buffer caches).
> > >
> > > Is there any finer granularity than a DIMM or pmem namespace for
> > > specifying encrypted regions? Note that filesystems are not aware of
> > > the physical layout of the memory address space (i.e. what DIMM
> > > corresponds to which sector in the block device), so DIMM-level
> > > granularity doesn't seem particularly useful right now....
> > >
> > > Also, how many different hardware encryption keys are available for
> > > use, and how many separate memory regions can a single key have
> > > associated with it?
> > >
> > > > However, if encrypted data were placed on a
> > > > filesystem, it might be in its encrypted state for long periods of =
time
> > > > and could not be moved by the filesystem during that time.
> > >
> > > I'm not sure what you mean by "if encrypted data were placed on a
> > > filesystem", given that the memory encryption is transparent to the
> > > filesystem (i.e. happens in the memory controller on it's way
> > > to/from the physical storage).
> > >
> > > > The =E2=80=9Ceasy=E2=80=9D solution to this is to just require that=
 the encryption key
> > > > be present and programmed into the memory controller before data is
> > > > moved.  However, this means that filesystems would need to know whe=
n a
> > > > given block has been encrypted and can not be moved.
> > >
> > > I'm missing something here - how does the filesystem even get
> > > mounted if we haven't unlocked the device the filesystem is stored
> > > on? i.e. we need to unlock the entire memory region containing the
> > > filesystem so it can read and write it's metadata (which can be
> > > randomly spread all over the block device).
> > >
> > > And if we have to do that to mount the filesystem, then aren't we
> > > also unlocking all the same memory regions that contain user data
> > > and hence they can be moved?
> >
> > Yes, and this is the most likely scenario for enabling MKTME with
> > persistent memory. The filesystem will not be able to mount until the
> > entire physical address range (namespace device) is unlocked, and the
> > filesystem is kept unaware of the encryption. One key per namespace
> > device.
> >
> > > At what point do we end up with a filesystem mounted and trying to
> > > access a locked memory region?
> >
> > Another option is to enable encryption to be specified at mmap time
> > with the motivation of being able to use the file system for
> > provisioning instead of managing multiple namespaces.
>
> I'm assuming you are talking about DAX here, yes?
>
> Because fscrypt....
>
> > The filesystem
> > would need to be careful to use the key for any physical block
> > management, and a decision would need to be made about when/whether
> > read(2)/write(2) access cipher text .
>
> ... already handles all this via page cache coherency for
> mmap/read/write IO.

Oh!

/me checks

It handles mmap coherency by making the page cache be clear text, but
perhaps in the DAX case we can make it be coherent cipher text through
both paths.

> > The current thinking is that
> > this would be too invasive / restrictive for the filesystem, but it's
> > otherwise an interesting thought experiment for allowing the
> > filesystem to take on more physical-storage allocation
> > responsibilities.
>
> Actually what we want in the filesystem world is /hardware offload/
> abstractions in the filesystems, not "filesystem controls hardware
> specific physical storage features" mechanisms.
>
> i.e. if the filesystem/fscrypt can offload the encryption of the
> data to the IO path by passing the fscrypt key/info with the IO,
> then it works with everything, not just pmem.
>
> In the case of pmem+DAX+mmap(), it needs to associate the correct
> key with the memory region that is to be encrypted when it is
> mmap()d. Then the DAX subsystem can associate the key with the
> physical pages that are faulted during DAX access. If it's bio based
> IO going to the DAX driver, then the keys should be attached to the
> bio....
>
> fscrypt encrypt/decrypt is already done at the filesystem/bio
> interface layer via bounce buffers - it's not a great stretch to
> push this down a layer so that it can be offloaded to the underlying
> device if it is hardware encryption capable. fscrypt would really
> only be used for key management (like needs work to support
> arbitrary hardware keys) and in filesystem metadata encryption (e.g.
> filenames) in that case....

Thanks, yes, fscrypt needs a closer look. As far I can see at a quick
glance fscrypt has the same physical block inputs for the encryption
algorithm as MKTME so it seems it could be crafted as a drop in
accelerator for fscrypt for pmem block devices.

