From: Arun Sudhilal <getarunks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] mm: convert totalram_pages, totalhigh_pages and
 managed_pages to atomic.
Date: Tue, 23 Oct 2018 10:16:51 +0530
Message-ID: <CABOM9Zpq41Ox8wQvsNjgfCtwuqh6CnyeW1B09DWa1TQN+JKf0w@mail.gmail.com>
References: <1540229092-25207-1-git-send-email-arunks@codeaurora.org>
 <20181022181122.GK18839@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20181022181122.GK18839-2MMpYkNvuYDjFM9bn6wA6Q@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org, kemi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, linux-sctp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, kys-0li6OtcxBFHby3iVrkZq2A@public.gmane.org, sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, David1.Zhou-5C7GfCeVMHo@public.gmane.org, ptesarik-IBi9RG/b67k@public.gmane.org, mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org, ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jejb-6jwH94ZQLHl74goWV3ctuw@public.gmane.org, kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, marcos.souza.org-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, steven.hill-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, anthony.yznaga-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, neelx-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, guro-b10kYP2dOMg@public.gmane.org, len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vbabka-AlSwsSmVLrQ@public.gmane.org, linux-um-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, rppt-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, trond.myklebust-F/q8l9xzQnoyLce1RVWEUA@public.gmane.org, anton-yrGDUoBaLx3QT0dZR+AlfA@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, malat-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cyrilbur@gma
List-Id: linux-mm.kvack.org

On Mon, Oct 22, 2018 at 11:41 PM Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> On Mon 22-10-18 22:53:22, Arun KS wrote:
> > Remove managed_page_count_lock spinlock and instead use atomic
> > variables.
>

Hello Michal,
> I assume this has been auto-generated. If yes, it would be better to
> mention the script so that people can review it and regenerate for
> comparision. Such a large change is hard to review manually.

Changes were made partially with script.  For totalram_pages and
totalhigh_pages,

find dir -type f -exec sed -i
's/totalram_pages/atomic_long_read(\&totalram_pages)/g' {} \;
find dir -type f -exec sed -i
's/totalhigh_pages/atomic_long_read(\&totalhigh_pages)/g' {} \;

For managed_pages it was mostly manual edits after using,
find mm/ -type f -exec sed -i
's/zone->managed_pages/atomic_long_read(\&zone->managed_pages)/g' {}
\;

Regards,
Arun

> --
> Michal Hocko
> SUSE Labs
