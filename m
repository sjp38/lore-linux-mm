Received: by wf-out-1314.google.com with SMTP id 25so1965031wfc.11
        for <linux-mm@kvack.org>; Fri, 21 Mar 2008 19:40:23 -0700 (PDT)
Message-ID: <8bd0f97a0803211940s6d7b5214q57f4f9eabd11a991@mail.gmail.com>
Date: Fri, 21 Mar 2008 22:40:23 -0400
From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: [2/2] vmallocinfo: Add caller information
In-Reply-To: <20080321205559.GC3509@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318222701.788442216@sgi.com>
	 <20080318222827.519656153@sgi.com> <20080319214227.GA4454@elte.hu>
	 <Pine.LNX.4.64.0803191659410.4645@schroedinger.engr.sgi.com>
	 <20080321110008.GW20420@elte.hu>
	 <Pine.LNX.4.64.0803211034140.18671@schroedinger.engr.sgi.com>
	 <20080321184526.GB6571@elte.hu>
	 <Pine.LNX.4.64.0803211212520.19558@schroedinger.engr.sgi.com>
	 <20080321205559.GC3509@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 21, 2008 at 4:55 PM, Ingo Molnar <mingo@elte.hu> wrote:
>  * Christoph Lameter <clameter@sgi.com> wrote:
>  > > the best i found for lockdep was to include a fair number of them,
>  > > and to skip the top 3. struct vm_area that vmalloc uses isnt
>  > > space-critical, so 4-8 entries with a 3 skip would be quite ok. (but
>  > > can be more than that as well)
>  >
>  > STACKTRACE depends on STACKTRACE_SUPPORT which is not available on all
>  > arches? alpha blackfin ia64 etc are missing it?
>
>  one more reason for them to implement it.

as long as the new code in question is properly ifdef-ed, making it
rely on STACKTRACE sounds fine.  i'll open an item in our Blackfin
tracker to add support for it.
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
