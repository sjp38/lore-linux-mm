Message-ID: <47EA7030.2080301@sgi.com>
Date: Wed, 26 Mar 2008 08:48:00 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/10] NR_CPUS: third reduction of NR_CPUS memory usage
 x86-version v2
References: <20080325220650.835342000@polaris-admin.engr.sgi.com> <20080326063401.GE18301@elte.hu>
In-Reply-To: <20080326063401.GE18301@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> * Mike Travis <travis@sgi.com> wrote:
> 
>> Wii, isn't this fun...!  This is a resubmission of yesterday's patches 
>> based on the x86.git/latest tree.  Yes, it _is_ a maze of twisty litle 
>> passages. ;-)
> 
> just to make patch dependencies clear: most of the patches here can be 
> applied to their base trees as-is, without depending on any other patch, 
> correct?
> 
> the only undeclared dependency i found was the cpumask_scnprintf_len() 
> patch - please prominently list dependencies in the changelog like this:
> 
>  [ this patch depends on "cpumask: Add cpumask_scnprintf_len function" ]
> 
> 	Ingo


Ahh, ok.  I was under the assumption that an entire patchset would be
applied en-mass and only divided up by bi-sect debugging...?

The second patchset (cpumask) is highly incremental and I did it like
this to show memory gains (or losses).  I tossed a few patches that
didn't have any overall goodness (and have a few more to help with
the memory footprint or performance in the queue.)

Thanks,
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
