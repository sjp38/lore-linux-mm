Date: Wed, 13 Feb 2008 07:59:29 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [RFC] [PATCH 4/4] Add soft limit documentation
Message-Id: <20080213075929.52a3ae05.randy.dunlap@oracle.com>
In-Reply-To: <20080213151256.7529.59791.sendpatchset@localhost.localdomain>
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain>
	<20080213151256.7529.59791.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Paul Menage <menage@google.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008 20:42:56 +0530 Balbir Singh wrote:

> 
> Add documentation for the soft limit feature.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  Documentation/controllers/memory.txt |   16 ++++++++++++++++
>  1 file changed, 16 insertions(+)
> 
> diff -puN Documentation/controllers/memory.txt~memory-controller-add-soft-limit-documentation Documentation/controllers/memory.txt
> --- linux-2.6.24/Documentation/controllers/memory.txt~memory-controller-add-soft-limit-documentation	2008-02-13 18:45:40.000000000 +0530
> +++ linux-2.6.24-balbir/Documentation/controllers/memory.txt	2008-02-13 18:49:58.000000000 +0530
> @@ -201,6 +201,22 @@ The memory.force_empty gives an interfac
>  
>  will drop all charges in cgroup. Currently, this is maintained for test.
>  
> +The file memory.soft_limit_in_bytes allows users to set soft limits. A soft
> +limit is set in a manner similar to limit. The limit feature described
> +earlier is a hard limit, a group can never exceed it's hard limit. A soft

                          ;  [or: ". A group ..."]
and s/it's/its/

> +limit on the other hand can be exceeded. A group will be shrunk back
> +to it's soft limit, when there is memory pressure/contention.

      its  [it's == it is]

> +
> +Ideally the soft limit should always be set to a value smaller than the
> +hard limit. However, the code does not force the user to do so. The soft
> +limit can be greater than the hard limit; then the soft limit has
> +no meaning in that setup, since the group will alwasy be restrained to its

                                                  always

> +hard limit.
> +
> +Example setting of soft limit
> +
> +# echo -n 100M > memory.soft_limit_in_bytes
> +
>  4. Testing

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
