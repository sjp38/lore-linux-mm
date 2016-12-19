Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB8AF6B02BD
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 16:12:01 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 75so94348245ite.7
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 13:12:01 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n80si14318673ioe.16.2016.12.19.13.12.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 13:12:00 -0800 (PST)
Date: Mon, 19 Dec 2016 14:11:49 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20161219211149.GA12822@linux.intel.com>
References: <20160912213435.GD30497@dastard>
 <20160913115311.509101b0@roar.ozlabs.ibm.com>
 <20160914073902.GQ22388@dastard>
 <20160914201936.08315277@roar.ozlabs.ibm.com>
 <20160915023133.GR22388@dastard>
 <20160915134945.0aaa4f5a@roar.ozlabs.ibm.com>
 <20160915103210.GT22388@dastard>
 <20160915214222.505f4888@roar.ozlabs.ibm.com>
 <20160915223350.GU22388@dastard>
 <20160916155405.6b634bbc@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160916155405.6b634bbc@roar.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiaof Guangrong <guangrong.xiao@linux.intel.com>, KVM list <kvm@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Linux MM <linux-mm@kvack.org>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Sep 16, 2016 at 03:54:05PM +1000, Nicholas Piggin wrote:
<>
> Definitely the first step would be your simple preallocated per
> inode approach until it is shown to be insufficient.

Reviving this thread a few months later...

Dave, we're interested in taking a serious look at what it would take to get
PMEM_IMMUTABLE working.  Do you still hold the opinion that this is (or could
become, with some amount of work) a workable solution?

We're happy to do the grunt work for this feature, but we will probably need
guidance from someone with more XFS experience.  With you out on extended leave
the first half of 2017, who would be the best person to ask for this guidance?
Darrick?

Thanks,
- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
