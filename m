Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id D68076B0007
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 13:36:26 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id p23-v6so1571383otl.23
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 10:36:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q24sor8986842otc.98.2018.10.09.10.36.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 10:36:25 -0700 (PDT)
MIME-Version: 1.0
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153861932401.2863953.11364943845583542894.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20181004074838.GE22173@dhcp22.suse.cz> <CAPcyv4jO_K8g3XRzuYOQPeGT--aPtucwZsqkywxOFO4Zny5Xrg@mail.gmail.com>
 <20181009111209.GL8528@dhcp22.suse.cz>
In-Reply-To: <20181009111209.GL8528@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 9 Oct 2018 10:36:14 -0700
Message-ID: <CAPcyv4hcVG7V07d0gT4mQjOLrZnesWvVg7cOuUhxCg=+F5qYMA@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] mm: Shuffle initial free memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Oct 9, 2018 at 4:16 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 04-10-18 09:51:37, Dan Williams wrote:
> > On Thu, Oct 4, 2018 at 12:48 AM Michal Hocko <mhocko@kernel.org> wrote:
[..]
> > So the reason front-back randomization is not enough is due to the
> > in-order initial freeing of pages. At the start of that process
> > putting page1 in front or behind page0 still keeps them close
> > together, page2 is still near page1 and has a high chance of being
> > adjacent. As more pages are added ordering diversity improves, but
> > there is still high page locality for the low address pages and this
> > leads to no significant impact to the cache conflict rate. Patch3 is
> > enough to keep the entropy sustained over time, but it's not enough
> > initially.
>
> That should be in the changelog IMHO.

Fair enough, I'll fold that in when I rebase on top of -next.
