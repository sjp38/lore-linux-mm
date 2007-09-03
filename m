Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id l834rSQX004682
	for <linux-mm@kvack.org>; Sun, 2 Sep 2007 21:53:28 -0700
Received: from an-out-0708.google.com (anac25.prod.google.com [10.100.54.25])
	by zps78.corp.google.com with ESMTP id l834rNcf002689
	for <linux-mm@kvack.org>; Sun, 2 Sep 2007 21:53:23 -0700
Received: by an-out-0708.google.com with SMTP id c25so237163ana
        for <linux-mm@kvack.org>; Sun, 02 Sep 2007 21:53:23 -0700 (PDT)
Message-ID: <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com>
Date: Sun, 2 Sep 2007 21:53:22 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface (v3)
In-Reply-To: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On 9/2/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> -       s += sprintf(s, "%lu\n", *val);
> +       if (read_strategy)
> +               s += read_strategy(*val, s);
> +       else
> +               s += sprintf(s, "%lu\n", *val);

This would be better as %llu

> +               tmp = simple_strtoul(buf, &end, 10);

and this as simple_strtoull()

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
