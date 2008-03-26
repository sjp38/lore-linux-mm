Received: by py-out-1112.google.com with SMTP id f47so3504404pye.20
        for <linux-mm@kvack.org>; Tue, 25 Mar 2008 20:22:09 -0700 (PDT)
Message-ID: <5d6222a80803252022n208abd1bieda5cfc4920e2b0c@mail.gmail.com>
Date: Wed, 26 Mar 2008 00:22:07 -0300
From: "Glauber Costa" <glommer@gmail.com>
Subject: Re: [RFC 8/8] x86_64: Support for new UV apic
In-Reply-To: <47E9B398.3080008@goop.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324182122.GA28327@sgi.com> <87abknhzhd.fsf@basil.nowhere.org>
	 <20080325175657.GA6262@sgi.com>
	 <20080325180616.GX2170@one.firstfloor.org> <47E9B398.3080008@goop.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Andi Kleen <andi@firstfloor.org>, Jack Steiner <steiner@sgi.com>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 25, 2008 at 11:23 PM, Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> Andi Kleen wrote:
>  > No instead of having lots of if (xyz_system) do_xyz_special()
>  > go through smp_ops for the whole thing so that UV would just have a
>  > special smp_ops that has special implementions or wrappers.
>  >
>  > Oops I see smp_ops are currently only implemented
>  > for 32bit. Ok do it only once smp_ops exist on 64bit too.
>  >
>
>  I think glommer has patches to unify smp stuff, which should include
>  smp_ops.
>

They are already merged in ingo's tree.

I'm still about to post some last-minute issues, but the full smp_ops
support is there.
-- 
Glauber Costa.
"Free as in Freedom"
http://glommer.net

"The less confident you are, the more serious you have to act."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
