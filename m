Received: by wr-out-0506.google.com with SMTP id c37so238025wra.26
        for <linux-mm@kvack.org>; Thu, 17 Apr 2008 11:02:18 -0700 (PDT)
Message-ID: <86802c440804171102q2be96c67m881394c1e6fa3867@mail.gmail.com>
Date: Thu, 17 Apr 2008 11:02:13 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH] - Increase MAX_APICS for large configs
In-Reply-To: <20080417110727.GA942@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080416163936.GA23099@sgi.com> <20080417110727.GA942@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 17, 2008 at 4:07 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
>  * Jack Steiner <steiner@sgi.com> wrote:
>
>  > Increase the maximum number of apics when running very large
>  > configurations. This patch has no affect on most systems.
>
>  x86.git overnight random-qa testing found a boot crash and i bisected it
>  down to this patch. The config is:
>
>   http://redhat.com/~mingo/misc/config-Thu_Apr_17_10_17_14_CEST_2008.bad
>
>  the failure is attached below. (I needed the exact boot parameters
>  listed in that bootup log to see this failure.)
>
>  it seems to be CONFIG_MAXSMP=y triggers the new more-apic-ids code and
>  that causes some breakage elsewhere. [btw., this again shows how useful
>  the CONFIG_MAXSMP debug feature is!]

so this one and Mike's 4096 NR_CPUS cause the problem?

2048 CPUs works.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
