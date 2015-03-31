Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 072E66B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 20:14:55 -0400 (EDT)
Received: by igbud6 with SMTP id ud6so4458214igb.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 17:14:54 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0119.hostedemail.com. [216.40.44.119])
        by mx.google.com with ESMTP id o78si10323990ioe.0.2015.03.30.17.14.54
        for <linux-mm@kvack.org>;
        Mon, 30 Mar 2015 17:14:54 -0700 (PDT)
Message-ID: <1427760888.14276.37.camel@perches.com>
Subject: Re: [PATCH 00/25] treewide: Use bool function return values of
 true/false not 1/0
From: Joe Perches <joe@perches.com>
Date: Mon, 30 Mar 2015 17:14:48 -0700
In-Reply-To: <5519E53B.5040504@schaufler-ca.com>
References: <cover.1427759009.git.joe@perches.com>
	 <5519E53B.5040504@schaufler-ca.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org, linux-omap@vger.kernel.org, kvm-ppc@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-ide@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-mm@kvack.org, linux-pm@vger.kernel.org, netdev@vger.kernel.org, alsa-devel@alsa-project.org, bridge@lists.linux-foundation.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, patches@opensource.wolfsonmicro.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org

On Mon, 2015-03-30 at 17:07 -0700, Casey Schaufler wrote:
> On 3/30/2015 4:45 PM, Joe Perches wrote:
> > Joe Perches (25):
> >   arm: Use bool function return values of true/false not 1/0

[etc...]

> Why, and why these in particular?

bool functions are probably better returning
bool values instead of 1 and 0.

Especially when the functions intermix returning
returning 1/0 and true/false.

(there are only a couple of those though)

These are all the remaining instances in the
kernel tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
