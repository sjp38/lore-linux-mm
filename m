Date: Wed, 26 Mar 2008 07:34:01 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00/10] NR_CPUS: third reduction of NR_CPUS memory usage
	x86-version v2
Message-ID: <20080326063401.GE18301@elte.hu>
References: <20080325220650.835342000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080325220650.835342000@polaris-admin.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Mike Travis <travis@sgi.com> wrote:

> Wii, isn't this fun...!  This is a resubmission of yesterday's patches 
> based on the x86.git/latest tree.  Yes, it _is_ a maze of twisty litle 
> passages. ;-)

just to make patch dependencies clear: most of the patches here can be 
applied to their base trees as-is, without depending on any other patch, 
correct?

the only undeclared dependency i found was the cpumask_scnprintf_len() 
patch - please prominently list dependencies in the changelog like this:

 [ this patch depends on "cpumask: Add cpumask_scnprintf_len function" ]

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
