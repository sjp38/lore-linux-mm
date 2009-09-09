Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A164E6B007E
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 09:22:17 -0400 (EDT)
Received: by yxe10 with SMTP id 10so7310856yxe.12
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 06:22:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090909120407.GA3598@cmpxchg.org>
References: <alpine.DEB.2.00.0909032146130.10307@kernelhack.brc.ubc.ca>
	 <alpine.DEB.2.00.0909040856030.17650@kernelhack.brc.ubc.ca>
	 <20090907083603.2C74.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.0909081106490.24907@kernelhack.brc.ubc.ca>
	 <20090909120407.GA3598@cmpxchg.org>
Date: Wed, 9 Sep 2009 22:22:24 +0900
Message-ID: <28c262360909090622m3ad2e4hbe9d43bd149a7d1@mail.gmail.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
	sc->isolate_pages() return value.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vincent Li <macli@brc.ubc.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 9, 2009 at 9:04 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Sep 08, 2009 at 11:32:45AM -0700, Vincent Li wrote:
>> On Mon, 7 Sep 2009, KOSAKI Motohiro wrote:
>>
>> > > > =A0[ Sending Preferences ]
>> > > > =A0 =A0 =A0 [X] =A0Do Not Send Flowed Text
>> > > > =A0 =A0 =A0 [ ] =A0Downgrade Multipart to Text
>> > > > =A0 =A0 =A0 [X] =A0Enable 8bit ESMTP Negotiation =A0 =A0(default)
>> > > > =A0 =A0 =A0 [ ] =A0Strip Whitespace Before Sending
>> > > >
>> > > > And Documentation/email-clients.txt have:
>> > > >
>> > > > Config options:
>> > > > - quell-flowed-text is needed for recent versions
>> > > > - the "no-strip-whitespace-before-send" option is needed
>> > > >
>> > > > Am I the one to blame? Should I uncheck the 'Do Not Send Flowed Te=
xt'? I
>> > > > am sorry if it is my fault.
>> > >
>> > > Ah, I quoted the pine Config options, the alpine config options from
>> > > Documentation/email-clients.txt should be:
>> > >
>> > > Config options:
>> > > In the "Sending Preferences" section:
>> > >
>> > > - "Do Not Send Flowed Text" must be enabled
>> > > - "Strip Whitespace Before Sending" must be disabled
>> >
>> > Can you please make email-clients.txt fixing patch too? :-)
>>
>> Sorry my poor written English make you confused.:-). The two config
>> options for alpine are already in email-clients.txt and I followed the e=
xisting config options
>> recommendation. I am not sure if my alpine is the faulty email client. I=
s
>> there still something missing with alpine?
>
> It seems it was Minchan's mail
> <28c262360909031837j4e1a9214if6070d02cb4fde04@mail.gmail.com> that
> replaced ascii spacing with some utf8 spacing characters.

Sigh.

I often use two mail client.
One of them is goolge web mail.
I guess that's mail was sent by google web mail which
changed ascii to utf8.
But I am not sure that's because I have been used it by ascii option.
Anyway, Sorry for noising.

Now I use google web mail and I hope this mail is going to send
properly. ;-(


> It is arguable whether this conversion was sensible but a bit sad
> that, apparently, by mid 2009 still not every email client is able to
> cope. :/
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
