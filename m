Received: by el-out-1112.google.com with SMTP id z25so341382ele.8
        for <linux-mm@kvack.org>; Fri, 22 Feb 2008 04:06:29 -0800 (PST)
Message-ID: <e2e108260802220406t78edf453g7e611d3fe4e644e1@mail.gmail.com>
Date: Fri, 22 Feb 2008 13:06:28 +0100
From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: SMP-related kernel memory leak
In-Reply-To: <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <e2e108260802190300k5b0f60f6tbb4f54997caf4c4e@mail.gmail.com>
	 <6101e8c40802191018t668faf3avba9beeff34f7f853@mail.gmail.com>
	 <e2e108260802192327v124a841dnc7d9b1c7e9057545@mail.gmail.com>
	 <6101e8c40802201342y7e792e70lbd398f84a58a38bd@mail.gmail.com>
	 <e2e108260802210048y653031f3r3104399f126336c5@mail.gmail.com>
	 <e2e108260802210800x5f55fee7ve6e768607d73ceb0@mail.gmail.com>
	 <6101e8c40802210821w626bc831uaf4c3f66fb097094@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oliver Pinter <oliver.pntr@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2008 at 5:21 PM, Oliver Pinter <oliver.pntr@gmail.com> wrote:
> it is reproductable with SLUB?
>  /* sorry for the bad english, but i not learned it .. */

The behavior with SLUB is similar but slightly different than the SLAB
behavior: with SLUB I see that memory usage increases faster and the
upper limit is a little bit lower. I will add the updated graph to the
bugzilla entry.

Bart Van Assche.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
