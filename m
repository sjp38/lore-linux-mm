Received: by ug-out-1314.google.com with SMTP id c2so32999ugf
        for <linux-mm@kvack.org>; Tue, 10 Jul 2007 21:25:41 -0700 (PDT)
Message-ID: <b8bf37780707102125x372be0adx1521510cf22c27e7@mail.gmail.com>
Date: Wed, 11 Jul 2007 00:25:40 -0400
From: "=?ISO-8859-1?Q?Andr=E9_Goddard_Rosa?=" <andre.goddard@gmail.com>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <b8bf37780707101852g25d835b4ubbf8da5383755d4b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <200707102015.44004.kernel@kolivas.org>
	 <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>
	 <20070710181419.6d1b2f7e.akpm@linux-foundation.org>
	 <b8bf37780707101852g25d835b4ubbf8da5383755d4b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/10/07, Andre Goddard Rosa <andre.goddard@gmail.com> wrote:
> On 7/10/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed, 11 Jul 2007 11:02:56 +1000 "Matthew Hawkins" <darthmdh@gmail.com>
> wrote:
> >
> > > We all know swap prefetch has been tested out the wazoo since Moses was
> a
> > > little boy, is compile-time and runtime selectable, and gives an
> important
> > > and quantifiable performance increase to desktop systems.
> >
> > Always interested.  Please provide us more details on your usage and
> > testing of that code.  Amount of memory, workload, observed results,
> > etc?
> >

It keeps my machine responsive after some time of inactivity,
i.e.  when I try to use firefox in the morning after leaving it running
overnight with multiple tabs open. I have 1Gb of memory in this machine.

With regards,
-- 
[]s,
Andre Goddard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
