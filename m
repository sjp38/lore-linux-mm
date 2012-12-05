Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D6B256B0068
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 17:39:43 -0500 (EST)
Message-ID: <1354746668.21585.147.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH v3 0/3] acpi: Introduce prepare_remove device
 operation
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 05 Dec 2012 15:31:08 -0700
In-Reply-To: <50BF399B.7010404@huawei.com>
References: 
	<1353693037-21704-1-git-send-email-vasilis.liaskovitis@profitbricks.com>
	     <50B5EFE9.3040206@huawei.com>
	    <1354128096.26955.276.camel@misato.fc.hp.com>
	   <50B6E936.2080308@huawei.com> <1354228028.7776.56.camel@misato.fc.hp.com>
	   <50BC29C6.6050706@huawei.com>
	 <1354579848.21585.54.camel@misato.fc.hp.com>  <50BDBF5A.8040407@huawei.com>
	 <1354663411.21585.135.camel@misato.fc.hp.com> <50BF399B.7010404@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <guohanjun@huawei.com>
Cc: Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, linux-acpi@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, rjw@sisk.pl, lenb@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tang Chen <tangchen@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, Huxinwei <huxinwei@huawei.com>

On Wed, 2012-12-05 at 20:10 +0800, Hanjun Guo wrote:
> On 2012/12/5 7:23, Toshi Kani wrote:
> > On Tue, 2012-12-04 at 17:16 +0800, Hanjun Guo wrote:
> >> On 2012/12/4 8:10, Toshi Kani wrote:
> >>> On Mon, 2012-12-03 at 12:25 +0800, Hanjun Guo wrote:
> >>>> On 2012/11/30 6:27, Toshi Kani wrote:
> >>>
> >>> If I read the code right, the framework calls ACPI drivers differently
> >>> at boot-time and hot-add as follows.  That is, the new entry points are
> >>> called at hot-add only, but .add() is called at both cases.  This
> >>> requires .add() to work differently.
> >>
> >> Hi Toshi,
> >> Thanks for your comments!
> >>
> >>>
> >>> Boot    : .add()
> >>
> >> Actually, at boot time: .add(), .start()
> > 
> > Right.
> > 
> >>> Hot-Add : .add(), .pre_configure(), configure(), etc.
> >>
> >> Yes, we did it as you said in the framework. We use .pre_configure(), configure(),
> >> and post_configure() to instead of .start() for better error handling and recovery.
> > 
> > I think we should have hot-plug interfaces at the module level, not at
> > the ACPI-internal level.  In this way, the interfaces can be
> > platform-neutral and allow any modules to register, which makes it more
> > consistent with the boot-up sequence.  It can also allow ordering of the
> > sequence among the registered modules.  Right now, we initiate all
> > procedures from ACPI during hot-plug, which I think is inflexible and
> > steps into other module's role.
> > 
> > I am also concerned about the slot handling, which is the core piece of
> > the infrastructure and only allows hot-plug operations on ACPI objects
> > where slot objects are previously created by checking _EJ0.  The
> > infrastructure should allow hot-plug operations on any objects, and it
> > should not be dependent on the slot design.
> > 
> > I have some rough idea, and it may be easier to review / explain if I
> > make some code changes.  So, let me prototype it, and send it you all if
> > that works out.  Hopefully, it won't take too long.
> 
> Great! If any thing I can do, please let me know it.

Cool.  Yes, if the prototype turns out to be a good one, we can work
together to improve it. :)
 
Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
