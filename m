Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1AB6D6B000D
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:23:20 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id a7-v6so5334686wmg.0
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:23:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b26-v6si626907edr.445.2018.06.11.10.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 10:23:18 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5BHJCjq100533
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:23:16 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jhu83pj52-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 13:23:16 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 11 Jun 2018 18:23:13 +0100
Date: Mon, 11 Jun 2018 10:23:05 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
 <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
 <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
 <20180604190229.GB10088@ram.oc3035372033.ibm.com>
 <30040030-1aa2-623b-beec-dd1ceb3eb9a7@redhat.com>
 <20180608023441.GA5573@ram.oc3035372033.ibm.com>
 <2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
MIME-Version: 1.0
In-Reply-To: <2858a8eb-c9b5-42ce-5cfc-74a4b3ad6aa9@redhat.com>
Message-Id: <20180611172305.GB5697@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, Jun 08, 2018 at 07:53:51AM +0200, Florian Weimer wrote:
> On 06/08/2018 04:34 AM, Ram Pai wrote:
> >>
> >>So the remaining question at this point is whether the Intel
> >>behavior (default-deny instead of default-allow) is preferable.
> >
> >Florian, remind me what behavior needs to fixed?
> 
> See the other thread.  The Intel register equivalent to the AMR by
> default disallows access to yet-unallocated keys, so that threads
> which are created before key allocation do not magically gain access
> to a key allocated by another thread.

Are you referring to the thread
'[PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change signal semantics'

If yes, I will wait for your next version of the patch.

Otherwise please point me to the URL of that thread. Sorry and thankx. :)
RP
