Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id A514E6B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 17:21:02 -0400 (EDT)
Date: Mon, 24 Sep 2012 14:21:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: divide error: bdi_dirty_limit+0x5a/0x9e
Message-Id: <20120924142100.52a1e7b7.akpm@linux-foundation.org>
In-Reply-To: <20120924201726.GB30997@quack.suse.cz>
References: <20120924102324.GA22303@aftab.osrc.amd.com>
	<20120924142305.GD12264@quack.suse.cz>
	<20120924143609.GH22303@aftab.osrc.amd.com>
	<20120924201650.6574af64.conny.seidel@amd.com>
	<20120924181927.GA25762@aftab.osrc.amd.com>
	<5060AB0E.3070809@linux.vnet.ibm.com>
	<20120924193135.GB25762@aftab.osrc.amd.com>
	<20120924200737.GA30997@quack.suse.cz>
	<20120924201726.GB30997@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Borislav Petkov <bp@amd64.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Conny Seidel <conny.seidel@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Fengguang Wu <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 24 Sep 2012 22:17:26 +0200
Jan Kara <jack@suse.cz> wrote:

>   In the attachment is a fix. Fengguang, can you please merge it? Thanks!

I grabbed it.  I also added the (missing, important) text "This bug causes
a divide-by-zero oops in bdi_dirty_limit() in Borislav's 3.6.0-rc6
based kernel." And I stuck a cc:stable onto it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
