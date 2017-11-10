Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B36CD28028E
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 06:37:08 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id j202so292408qke.2
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 03:37:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l64sor5199171qte.92.2017.11.10.03.37.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 03:37:07 -0800 (PST)
Date: Fri, 10 Nov 2017 09:36:56 -0200
From: Breno Leitao <leitao@debian.org>
Subject: Re: [PATCH v9 44/51] selftest/vm: powerpc implementation for generic
 abstraction
Message-ID: <20171110113655.hizq4xes5oy2fzim@gmail.com>
References: <1509958663-18737-1-git-send-email-linuxram@us.ibm.com>
 <1509958663-18737-45-git-send-email-linuxram@us.ibm.com>
 <20171109184714.xs523k4cvmqghew3@gmail.com>
 <20171109233745.GD5546@ram.oc3035372033.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171109233745.GD5546@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de, linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

Hi Ram,

On Thu, Nov 09, 2017 at 03:37:46PM -0800, Ram Pai wrote:
> On Thu, Nov 09, 2017 at 04:47:15PM -0200, Breno Leitao wrote:
> > On Mon, Nov 06, 2017 at 12:57:36AM -0800, Ram Pai wrote:
> > > @@ -206,12 +209,14 @@ void signal_handler(int signum, siginfo_t *si, void *vucontext)
> > >  
> > >  	trapno = uctxt->uc_mcontext.gregs[REG_TRAPNO];
> > >  	ip = uctxt->uc_mcontext.gregs[REG_IP_IDX];
> > > -	fpregset = uctxt->uc_mcontext.fpregs;
> > > -	fpregs = (void *)fpregset;
> > 
> > Since you removed all references for fpregset now, you probably want to
> > remove the declaration of the variable above.
> 
> fpregs is still needed.

Right, fpregs is still needed, but not fpregset. Every reference for this
variable was removed with your patch.

Grepping this variable identifier on a tree with your patches, I see:

 $ grep fpregset protection_keys.c 
 fpregset_t fpregset;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
