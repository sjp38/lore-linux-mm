Date: Tue, 25 Feb 2003 15:46:26 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: 2.5.62-mm3 - no X for me
Message-ID: <359700000.1046209586@[10.1.1.5]>
In-Reply-To: <20030225132755.241e85ac.akpm@digeo.com>
References: <20030223230023.365782f3.akpm@digeo.com>
 <3E5A0F8D.4010202@aitel.hist.no><20030224121601.2c998cc5.akpm@digeo.com>
 <20030225094526.GA18857@gemtek.lt><20030225015537.4062825b.akpm@digeo.com>
 <131360000.1046195828@[10.1.1.5]> <20030225132755.241e85ac.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: zilvinas@gemtek.lt, helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--On Tuesday, February 25, 2003 13:27:55 -0800 Andrew Morton
<akpm@digeo.com> wrote:

>> Or I could set the anon flag based on that test.  I know page flags are
>> getting scarce, so I'm leaning toward removing the flag entirely.
>> 
>> What would you recommend?
> 
> Keep the flag for now, find the escaped page under X, remove the flag
> later?

It occurred to me I'm already using (abusing?) the flag for nonlinear
pages, so I have to keep it.  I'll chase solutions for X.

Dave McCracken
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
