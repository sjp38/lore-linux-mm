Date: Fri, 17 Aug 2007 11:48:04 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 02/23] lib: percpu_counter_add
Message-ID: <20070817154804.GC24323@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl> <20070816074624.963595000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070816074624.963595000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 16, 2007 at 09:45:27AM +0200, Peter Zijlstra wrote:
...
> Index: linux-2.6/fs/ext2/balloc.c
> ===================================================================
> --- linux-2.6.orig/fs/ext2/balloc.c
> +++ linux-2.6/fs/ext2/balloc.c
> @@ -163,7 +163,7 @@ static int reserve_blocks(struct super_b
>  			return 0;
>  	}
>  
> -	percpu_counter_mod(&sbi->s_freeblocks_counter, -count);
> +	percpu_counter_add(&sbi->s_freeblocks_counter, -count);

Out of curiosity, I noticed similar thing being done in the vm code, what is
preferred:

	foobar_add(&counter, -num);

or

	foobar_sub(&counter, num);

?

Josef 'Jeff' Sipek.

-- 
Research, n.:
  Consider Columbus:
    He didn't know where he was going.
    When he got there he didn't know where he was.
    When he got back he didn't know where he had been.
    And he did it all on someone else's money.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
