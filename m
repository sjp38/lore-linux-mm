Date: Mon, 11 Aug 2003 11:39:43 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test3-mm1
Message-Id: <20030811113943.47e5fd85.akpm@osdl.org>
In-Reply-To: <94490000.1060612530@[10.10.2.4]>
References: <20030809203943.3b925a0e.akpm@osdl.org>
	<94490000.1060612530@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> Degredation on kernbench is still there:
> 
> Kernbench: (make -j N vmlinux, where N = 16 x num_cpus)
>                               Elapsed      System        User         CPU
>               2.6.0-test3       45.97      115.83      571.93     1494.50
>           2.6.0-test3-mm1       46.43      122.78      571.87     1496.00
> 
> Quite a bit of extra sys time.

Increased system is a surprise.  Profiles would be interesting, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
