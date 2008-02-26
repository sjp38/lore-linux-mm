Received: by rv-out-0910.google.com with SMTP id f1so1434509rvb.26
        for <linux-mm@kvack.org>; Tue, 26 Feb 2008 05:31:51 -0800 (PST)
Message-ID: <44c63dc40802260531o2102759l4463e62fa9b78e1b@mail.gmail.com>
Date: Tue, 26 Feb 2008 22:31:51 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: Re: [RFC][PATCH] radix-tree based page_cgroup. [7/7] per cpu fast lookup
In-Reply-To: <44c63dc40802260526x3283baf2tb4ab71b384a4ab58@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080225120758.27648297.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080225121849.191ac900.kamezawa.hiroyu@jp.fujitsu.com>
	 <44c63dc40802260526x3283baf2tb4ab71b384a4ab58@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, taka@valinux.co.jp, Andi Kleen <ak@suse.de>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I knew you purpose with following patch <radix-tree based page_cgroup.
[8/7] vmalloc for large machines>
I am afraid your patch list isn't arranged well. :-<

On Tue, Feb 26, 2008 at 10:26 PM, minchan Kim <barrioskmc@gmail.com> wrote:
> >  -struct page_cgroup *get_page_cgroup(struct page *page, gfp_t gfpmask)
>  >  +struct page_cgroup *__get_page_cgroup(struct page *page, gfp_t gfpmask)
>  >   {
>  >         struct page_cgroup_root *root;
>  >         struct page_cgroup *pc, *base_addr;
>  >  @@ -96,8 +110,14 @@ retry:
>  >         pc = radix_tree_lookup(&root->root_node, idx);
>  >         rcu_read_unlock();
>  >
>  >  +       if (pc) {
>  >  +               if (!in_interrupt())
>  >  +                       save_result(pc, idx);
>  >  +       }
>  >  +
>
>  I didn't look through mem_control's patches yet.
>  Please understand me if my question might be foolish.
>
>  why do you prevent when it happen in interrupt context ?
>  Do you have any reason ?
>
>  --
>  Thanks,
>  barrios
>



-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
