Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id l847JYDr028589
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 00:19:34 -0700
Received: from an-out-0708.google.com (anac3.prod.google.com [10.100.54.3])
	by zps19.corp.google.com with ESMTP id l847JMvG012377
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 00:19:23 -0700
Received: by an-out-0708.google.com with SMTP id c3so323554ana
        for <linux-mm@kvack.org>; Tue, 04 Sep 2007 00:19:22 -0700 (PDT)
Message-ID: <6599ad830709040019r17861771we2a0893c0c160723@mail.gmail.com>
Date: Tue, 4 Sep 2007 00:19:22 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface (v3)
In-Reply-To: <46DC6543.3000607@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
	 <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com>
	 <46DC6543.3000607@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 9/3/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> Paul Menage wrote:
> > On 9/2/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >> -       s += sprintf(s, "%lu\n", *val);
> >> +       if (read_strategy)
> >> +               s += read_strategy(*val, s);
> >> +       else
> >> +               s += sprintf(s, "%lu\n", *val);
> >
> > This would be better as %llu
> >
>
> Hi, Paul,
>
> This does not need fixing, since the other counters like failcnt are
> still unsigned long
>

But val is an unsigned long long*. So printing *val with %lu will
break (at least a warning, and maybe corruption if you had other
parameters) on 32-bit archs.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
