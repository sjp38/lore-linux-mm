Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 10BF56B0007
	for <linux-mm@kvack.org>; Wed,  2 May 2018 19:39:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 74-v6so224219wme.0
        for <linux-mm@kvack.org>; Wed, 02 May 2018 16:39:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i93-v6si1512796edc.289.2018.05.02.16.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 May 2018 16:38:59 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w42Ncluv028919
	for <linux-mm@kvack.org>; Wed, 2 May 2018 19:38:58 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hqkdkyxdy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 May 2018 19:38:58 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 3 May 2018 00:38:56 +0100
Date: Wed, 2 May 2018 16:38:48 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <20180502211254.GA5863@ram.oc3035372033.ibm.com>
 <CALCETrUfO=vXg5rT-n=y8pLktcq5+ORvgpsOXCHG4GaugB3k2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUfO=vXg5rT-n=y8pLktcq5+ORvgpsOXCHG4GaugB3k2A@mail.gmail.com>
Message-Id: <20180502233848.GB5863@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Florian Weimer <fweimer@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev@lists.ozlabs.org

On Wed, May 02, 2018 at 09:18:11PM +0000, Andy Lutomirski wrote:
> On Wed, May 2, 2018 at 2:13 PM Ram Pai <linuxram@us.ibm.com> wrote:
> 
> 
> > > Ram, would you please comment?
> 
> > on POWER the pkey behavior will remain the same at entry or at exit from
> > the signal handler.  For eg:  if a key is read-disabled on entry into
> > the signal handler, and gets read-enabled in the signal handler, than it
> > will continue to be read-enabled on return from the signal handler.
> 
> > In other words, changes to key permissions persist across signal
> > boundaries.
> 
> I don't know about POWER's ISA, but this is crappy behavior.  If a thread
> temporarily grants itself access to a restrictive memory key and then gets
> a signal, the signal handler should *not* have access to that key.

This is a new requirement that I was not aware off. Its not documented
anywhere AFAICT.  Regardless of how the ISA behaves, its still a kernel
behavior that needs to be clearly defined.

-- 
Ram Pai
