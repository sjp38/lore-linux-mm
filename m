Date: Thu, 17 Apr 2008 16:40:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.25-mm1: not looking good
Message-Id: <20080417164034.e406ef53.akpm@linux-foundation.org>
In-Reply-To: <20080417160331.b4729f0c.akpm@linux-foundation.org>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu, tglx@linutronix.de, penberg@cs.helsinki.fi, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmorris@namei.org, sds@tycho.nsa.gov
List-ID: <linux-mm.kvack.org>

On Thu, 17 Apr 2008 16:03:31 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> I have maybe two hours in which to weed out whatever very-recently-added
> dud patches are causing this.  Any suggestions are welcome.
> 

With git-selinux at top-of tree it's repeatably hanging in the CPA
self-tests (git-x86 stuff).  Last two lines are:

CPA self-test:
 4k 8704 large 4847 gb 0 x 0[0-0] miss 0

(clear as mud ;))

I will find the config knob to disable that test.  Of course, it could be
telling me that CPA is buggy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
