Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B72266B0062
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 16:26:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q9so5767554pgp.16
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 13:26:17 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id j197si3227336pgc.809.2018.03.30.13.26.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Mar 2018 13:26:16 -0700 (PDT)
Subject: Re: [PATCH 00/11] Use global pages with PTI
References: <20180323174447.55F35636@viggo.jf.intel.com>
 <CA+55aFwEC1O+6qRc35XwpcuLSgJ+0GP6ciqw_1Oc-msX=efLvQ@mail.gmail.com>
 <be2e683c-bf0a-e9ce-2f02-4905f6bd56d3@linux.intel.com>
 <alpine.DEB.2.21.1803271526260.1964@nanos.tec.linutronix.de>
 <c0e7ca0b-dcb5-66e2-9df6-f53e4eb22781@linux.intel.com>
 <alpine.DEB.2.21.1803271949250.1618@nanos.tec.linutronix.de>
 <20180327200719.lvdomez6hszpmo4s@gmail.com>
 <0d6ea030-ec3b-d649-bad7-89ff54094e25@linux.intel.com>
 <20180330120920.btobga44wqytlkoe@gmail.com>
 <20180330121725.zcklh36ulg7crydw@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <3cdc23a2-99eb-6f93-6934-f7757fa30a3e@linux.intel.com>
Date: Fri, 30 Mar 2018 13:26:14 -0700
MIME-Version: 1.0
In-Reply-To: <20180330121725.zcklh36ulg7crydw@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, the arch/x86 maintainers <x86@kernel.org>, namit@vmware.com

On 03/30/2018 05:17 AM, Ingo Molnar wrote:
> BTW., the expectation on !PCID Intel hardware would be for global pages to help 
> even more than the 0.6% and 1.7% you measured on PCID hardware: PCID already 
> _reduces_ the cost of TLB flushes - so if there's not even PCID then global pages 
> should help even more.
> 
> In theory at least. Would still be nice to measure it.

I did the lseek test on a modern, non-PCID system:

No Global pages (baseline): 6077741 lseeks/sec
94 Global pages (this set): 8433111 lseeks/sec
			   +2355370 lseeks/sec (+38.8%)
