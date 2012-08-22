Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id CB2966B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 08:13:30 -0400 (EDT)
Received: by obhx4 with SMTP id x4so1636022obh.14
        for <linux-mm@kvack.org>; Wed, 22 Aug 2012 05:13:29 -0700 (PDT)
Message-ID: <5034CD02.2010103@gmail.com>
Date: Wed, 22 Aug 2012 14:13:54 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 13/17] lockd: use new hashtable implementation
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-14-git-send-email-levinsasha928@gmail.com> <20120822114752.GC20158@fieldses.org>
In-Reply-To: <20120822114752.GC20158@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On 08/22/2012 01:47 PM, J. Bruce Fields wrote:
> On Wed, Aug 22, 2012 at 04:27:08AM +0200, Sasha Levin wrote:
>> +static int __init nlm_init(void)
>> +{
>> +	hash_init(nlm_files);
>> +	return 0;
>> +}
>> +
>> +module_init(nlm_init);
> 
> That's giving me:
> 
> fs/lockd/svcsubs.o: In function `nlm_init':
> /home/bfields/linux-2.6/fs/lockd/svcsubs.c:454: multiple definition of `init_module'
> fs/lockd/svc.o:/home/bfields/linux-2.6/fs/lockd/svc.c:606: first defined here
> make[2]: *** [fs/lockd/lockd.o] Error 1
> make[1]: *** [fs/lockd] Error 2
> make[1]: *** Waiting for unfinished jobs....

I tested this entire patch set both with linux-next and Linus' latest master,
and it worked fine in both places.

Is it possible that lockd has a -next tree which isn't pulled into linux-next?
(there's nothing listed in MAINTAINERS that I could see).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
