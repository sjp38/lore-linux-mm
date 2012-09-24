Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 5BDED6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 18:27:27 -0400 (EDT)
Date: Tue, 25 Sep 2012 00:27:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-ID: <20120924222724.GD30997@quack.suse.cz>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
 <20120924142305.GD12264@quack.suse.cz>
 <20120924143609.GH22303@aftab.osrc.amd.com>
 <20120924201650.6574af64.conny.seidel@amd.com>
 <20120924181927.GA25762@aftab.osrc.amd.com>
 <5060AB0E.3070809@linux.vnet.ibm.com>
 <20120924193135.GB25762@aftab.osrc.amd.com>
 <20120924200737.GA30997@quack.suse.cz>
 <20120924201726.GB30997@quack.suse.cz>
 <20120924142100.52a1e7b7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120924142100.52a1e7b7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Borislav Petkov <bp@amd64.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Conny Seidel <conny.seidel@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon 24-09-12 14:21:00, Andrew Morton wrote:
> On Mon, 24 Sep 2012 22:17:26 +0200
> Jan Kara <jack@suse.cz> wrote:
> 
> >   In the attachment is a fix. Fengguang, can you please merge it? Thanks!
> 
> I grabbed it.  I also added the (missing, important) text "This bug causes
> a divide-by-zero oops in bdi_dirty_limit() in Borislav's 3.6.0-rc6
> based kernel." And I stuck a cc:stable onto it.
  Thanks!

								Honza

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
