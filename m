From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Disable the memory controller by default (v2)
Date: Mon, 7 Apr 2008 10:43:37 -0700
Message-ID: <6599ad830804071043j33212a6kbeb4ef7d79e17f5c@mail.gmail.com>
References: <20080407130215.26565.81715.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753105AbYDGRn5@vger.kernel.org>
In-Reply-To: <20080407130215.26565.81715.sendpatchset@localhost.localdomain>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel Emelianov <xemul@openvz.org>, hugh@veritas.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Mon, Apr 7, 2008 at 6:02 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>         return 1;
>   }
>   __setup("cgroup_disable=", cgroup_disable);
>  +
>  +static int __init cgroup_enable(char *str)
>  +{
>  +       int i;
>  +       char *token;
>  +
>  +       while ((token = strsep(&str, ",")) != NULL) {
>  +               if (!*token)
>  +                       continue;
>  +
>  +               for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>  +                       struct cgroup_subsys *ss = subsys[i];
>  +
>  +                       if (!strcmp(token, ss->name)) {
>  +                               ss->disabled = 0;
>  +                               printk(KERN_INFO "%s control group "
>  +                                               "is enabled\n", ss->name);
>  +                               break;
>  +                       }
>  +               }
>  +       }
>  +       return 1;
>  +}
>  +__setup("cgroup_enable=", cgroup_enable);

Good idea - but you could just use the same handler function for both
of these (with a one-line wrapper for each to pass disabled=1 or
disabled=0)

Paul
