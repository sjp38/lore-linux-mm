Subject: Re: [ck] Re: [PATCH] mm: yield during swap prefetching
From: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <b8bf37780603071852r6bf3821fr7610597a54ad305b@mail.gmail.com>
References: <200603081013.44678.kernel@kolivas.org>
	 <200603081322.02306.kernel@kolivas.org> <1141784834.767.134.camel@mindpipe>
	 <200603081330.56548.kernel@kolivas.org>
	 <b8bf37780603071852r6bf3821fr7610597a54ad305b@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Date: Tue, 07 Mar 2006 22:03:03 -0500
Message-Id: <1141786983.767.150.camel@mindpipe>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?ISO-8859-1?Q?Andr=E9?= Goddard Rosa <andre.goddard@gmail.com>
Cc: Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-03-07 at 22:52 -0400, Andre Goddard Rosa wrote:
> Sorry Con, but I have to disagree with you on this.
> 
> Games are very complex software, involving heavy use of hardware
> resources
> and they also have a lot of time constraints. So, I think they should
> use RT priorities
> if it is necessary to get the resources needed in time.
> 

The main reason I assumed games would want to use the POSIX realtime
features like priority scheduling etc. is that the simulation people all
use them - it seems like a very similar problem.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
