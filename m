Date: Tue, 24 Sep 2002 15:54:28 +0530
From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: Re: 2.5.38-mm2 [PATCH]
Message-ID: <20020924155428.B4085@in.ibm.com>
Reply-To: dipankar@in.ibm.com
References: <3D8E96AA.C2FA7D8@digeo.com> <20020923151559.B29900@in.ibm.com> <20020924144109.2cbbdb36.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020924144109.2cbbdb36.rusty@rustcorp.com.au>; from rusty@rustcorp.com.au on Tue, Sep 24, 2002 at 02:41:09PM +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: akpm@digeo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 24, 2002 at 02:41:09PM +1000, Rusty Russell wrote:
> On Mon, 23 Sep 2002 15:15:59 +0530
> Dipankar Sarma <dipankar@in.ibm.com> wrote:
> > Later I will submit a full rcu_ltimer patch that contains
> > the call_rcu_preempt() interface which can be useful for
> > module unloading and the likes. This doesn't affect
> > the non-preemption path.
> 
> You don't need this: I've dropped the requirement for module
> unload.

Isn't wait_for_later() similar to synchornize_kernel() or has the
entire module unloading design been changed since ?

Thanks
-- 
Dipankar Sarma  <dipankar@in.ibm.com> http://lse.sourceforge.net
Linux Technology Center, IBM Software Lab, Bangalore, India.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
