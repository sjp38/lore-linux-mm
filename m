Date: Tue, 18 Mar 2008 19:16:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH O/4] Block I/O tracking
Message-Id: <20080318191624.85ca135f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080318.182251.93858044.taka@valinux.co.jp>
References: <20080318.182251.93858044.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008 18:22:51 +0900 (JST)
Hirokazu Takahashi <taka@valinux.co.jp> wrote:

>  # mount -t cgroup -o bio none /cgroup/bio
> 
> Then, you make new bio cgroups and put some processes in them.
> 
>  # mkdir /cgroup/bio/bgroup1
>  # mkdir /cgroup/bio/bgroup2
>  # echo 1234 /cgroup/bio/bgroup1/tasks
>  # echo 5678 /cgroup/bio/bgroup1/tasks
> 
> Now you check the ids of the bio cgroups which you just created.
> 
>  # cat /cgroup/bio/bgroup1/bio.id
>    1
>  # cat /cgroup/bio/bgroup2/bio.id
>    2
> 
> Finally, you can attach the cgroups to "ioband1" and assign them weights.
> 
>  # dmsetup message ioband1 0 type cgroup
>  # dmsetup message ioband1 0 attach 1
>  # dmsetup message ioband1 0 attach 2
>  # dmsetup message ioband1 0 weight 1:30
>  # dmsetup message ioband1 0 weight 2:60
> 
> You can find the manual of dm-ioband at
> http://people.valinux.co.jp/~ryov/dm-ioband/manual/index.html.
> But the user interface for the bio cgroup is temporal and it will be
> changed after the io_context support. 
> 
I'm grad if these some kinds of params rather than 'id' are also shown
under cgroup.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
