Date: Tue, 24 Sep 2002 14:41:09 +1000
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: 2.5.38-mm2 [PATCH]
Message-Id: <20020924144109.2cbbdb36.rusty@rustcorp.com.au>
In-Reply-To: <20020923151559.B29900@in.ibm.com>
References: <3D8E96AA.C2FA7D8@digeo.com>
	<20020923151559.B29900@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dipankar@in.ibm.com
Cc: akpm@digeo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Sep 2002 15:15:59 +0530
Dipankar Sarma <dipankar@in.ibm.com> wrote:
> Later I will submit a full rcu_ltimer patch that contains
> the call_rcu_preempt() interface which can be useful for
> module unloading and the likes. This doesn't affect
> the non-preemption path.

You don't need this: I've dropped the requirement for module
unload.

Cheers!
Rusty.
-- 
   there are those who do and those who hang on and you don't see too
   many doers quoting their contemporaries.  -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
