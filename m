Received: by wr-out-0506.google.com with SMTP id c37so1147044wra.26
        for <linux-mm@kvack.org>; Mon, 31 Mar 2008 11:42:10 -0700 (PDT)
Message-ID: <86802c440803311142u4cbbdca9m830e86d46ad020af@mail.gmail.com>
Date: Mon, 31 Mar 2008 11:42:09 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
In-Reply-To: <20080331123338.GA14636@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324182122.GA28327@sgi.com> <20080325175657.GA6262@sgi.com>
	 <20080326073823.GD3442@elte.hu>
	 <86802c440803301323q5c4bd4f4k1f9bdc1d6b1a0a7b@mail.gmail.com>
	 <20080330210356.GA13383@sgi.com>
	 <20080330211848.GA29105@one.firstfloor.org>
	 <86802c440803301629g6d1b896o27e12ef3c84ded2c@mail.gmail.com>
	 <20080331021821.GC20619@sgi.com>
	 <86802c440803301920o47335876yac12a5a09d1a8cc9@mail.gmail.com>
	 <20080331123338.GA14636@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jack Steiner <steiner@sgi.com>, Andi Kleen <andi@firstfloor.org>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 31, 2008 at 5:33 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
>
>  * Yinghai Lu <yhlu.kernel@gmail.com> wrote:
>
>  > On Sun, Mar 30, 2008 at 7:18 PM, Jack Steiner <steiner@sgi.com> wrote:
>  > > >
>  > >  > if the calling path like GET_APIC_ID is keeping checking if it is
>  > >  > UV box after boot time, that may not good.
>  > >  >
>  > >  > don't need make other hundreds of machine keep running the code
>  > >  > only for several big box all the time.
>  > >  >
>  > >  > YH
>  > >
>  > >
>  > >  I added trace code to see how often GET_APIC_ID() is called. For my
>  > >  8p AMD box, the function is called 6 times per cpu during boot. I
>  > >  have not seen any other calls to the function after early boot
>  > >  although I'm they occur under some circumstances.
>  >
>  > then it is ok.
>
>  yes - and even if it were called more frequently, having generic code
>  and having the possibility of an as generic as possible kernel image
>  (and kernel rpms) is still a very important feature. In that sense
>  subarch support is actively harmful and we are trying to move away from
>  that model.

regarding LinuxBIOS = coreboot + TinyKernel. some box need to use
64bit kernel, because 32 bit kernel could mess up the 64 bit
resources, and final kernel kexeced is 64 bit.

and TinyKernel need to stay with coreboot in MB flash rom, and that
flash is about 2M...

So hope it is easier to use MACRO to mask platform detect code out.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
