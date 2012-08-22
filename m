Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 8F6216B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 07:48:04 -0400 (EDT)
Date: Wed, 22 Aug 2012 07:47:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v3 13/17] lockd: use new hashtable implementation
Message-ID: <20120822114752.GC20158@fieldses.org>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
 <1345602432-27673-14-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1345602432-27673-14-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Wed, Aug 22, 2012 at 04:27:08AM +0200, Sasha Levin wrote:
> +static int __init nlm_init(void)
> +{
> +	hash_init(nlm_files);
> +	return 0;
> +}
> +
> +module_init(nlm_init);

That's giving me:

fs/lockd/svcsubs.o: In function `nlm_init':
/home/bfields/linux-2.6/fs/lockd/svcsubs.c:454: multiple definition of `init_module'
fs/lockd/svc.o:/home/bfields/linux-2.6/fs/lockd/svc.c:606: first defined here
make[2]: *** [fs/lockd/lockd.o] Error 1
make[1]: *** [fs/lockd] Error 2
make[1]: *** Waiting for unfinished jobs....

--b.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
