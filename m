From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Tue, 1 Apr 2008 19:00:03 +0300
Message-ID: <84144f020804010900s5335988ai58546874a6a2f8bd@mail.gmail.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755208AbYDAQAV@vger.kernel.org>
In-Reply-To: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

Hi,

On Tue, Apr 1, 2008 at 3:43 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  @@ -227,8 +227,9 @@ struct mm_struct {
>         /* aio bits */
>         rwlock_t                ioctx_list_lock;
>         struct kioctx           *ioctx_list;
>  -#ifdef CONFIG_CGROUP_MEM_RES_CTLR
>  -       struct mem_cgroup *mem_cgroup;
>  +#ifdef CONFIG_MM_OWNER
>  +       struct task_struct *owner;      /* The thread group leader that */
>  +                                       /* owns the mm_struct.          */
>   #endif

Yes, please. This is useful for the revokeat() patches as well. I
currently need a big ugly loop to scan each task so I can break COW of
private pages.
