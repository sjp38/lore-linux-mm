Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 98A1C6B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 07:23:52 -0500 (EST)
Received: by obbbj7 with SMTP id bj7so58373999obb.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:23:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y6si6149947oei.53.2015.11.19.04.23.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 04:23:51 -0800 (PST)
Subject: Re: [kbuild-all] [patch -mm] mm, vmalloc: remove VM_VPAGES
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201511190854.Z8lkE4h1%fengguang.wu@intel.com>
	<alpine.DEB.2.10.1511181659290.8399@chino.kir.corp.google.com>
	<20151119113300.GA22395@wfg-t540p.sh.intel.com>
In-Reply-To: <20151119113300.GA22395@wfg-t540p.sh.intel.com>
Message-Id: <201511192123.DHI75684.FFHOOQSVMLOFJt@I-love.SAKURA.ne.jp>
Date: Thu, 19 Nov 2015 21:23:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkp@intel.com, rientjes@google.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kbuild-all@01.org, linux-kernel@vger.kernel.org

Fengguang Wu wrote:
> Hi David,
> 
> On Wed, Nov 18, 2015 at 05:00:07PM -0800, David Rientjes wrote:
> > On Thu, 19 Nov 2015, kbuild test robot wrote:
> > 
> > > Hi David,
> > > 
> > > [auto build test ERROR on: next-20151118]
> > > [also build test ERROR on: v4.4-rc1]
> > > 
> > 
> > You need to teach your bot what patches I'm proposing for the -mm tree 
> > (notice the patch title) instead of your various trees.
> 
> Per my understanding linux-next is the -mm tree.
> Or do you mean some standalone -mm git tree?
> 
> Thanks,
> Fengguang
> 

This build error will be gone when
"[PATCH] tree wide: Use kvfree() than conditional kfree()/vfree()"
(currently in -mm tree) is applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
