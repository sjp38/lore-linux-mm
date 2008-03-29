From: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Subject: Re: down_spin() implementation
Date: Sat, 29 Mar 2008 12:04:36 +1100
Message-ID: <200803291204.36855.nickpiggin@yahoo.com.au>
References: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com> <200803281101.25037.nickpiggin@yahoo.com.au> <20080328124517.GQ16721@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-arch-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080328124517.GQ16721-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
Content-Disposition: inline
Sender: linux-arch-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Matthew Wilcox <matthew-Ztpu424NOJ8@public.gmane.org>
Cc: "Luck, Tony" <tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: linux-mm.kvack.org

On Friday 28 March 2008 23:45, Matthew Wilcox wrote:

> I think we can do better here with:
>
> 	atomic_set(max);
>
> and
>
> 	while (unlikely(!atomic_add_unless(&ss->cur, -1, 0)))
> 		while (atomic_read(&ss->cur) == 0)
> 			cpu_relax();

Yeah of course! That's much better ;)

I'd say Tony could just open code it for now, which would get him
up and running quickly... although if anybody gets keen to add it
as a generic API then I wouldn't object.
