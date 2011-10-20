Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7296B6B002F
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 22:17:21 -0400 (EDT)
Received: by yxs7 with SMTP id 7so3071938yxs.14
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 19:17:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrU23vyCXPG6mJU9qaPeAGOWDQtur5C+LRT154V5FM=Ajg@mail.gmail.com>
References: <CALCETrXbPWsgaZmsvHZGEX-CxB579tG+zusXiYhR-13RcEnGvQ@mail.gmail.com>
	<ACE78D84-0E94-4E7A-99BF-C20583018697@dilger.ca>
	<CALCETrU23vyCXPG6mJU9qaPeAGOWDQtur5C+LRT154V5FM=Ajg@mail.gmail.com>
Date: Wed, 19 Oct 2011 19:17:18 -0700
Message-ID: <CALCETrX=-CnNQ9+4tRbqMG4mfuy2FBPXXoJeBVDVPnEiRJYRFQ@mail.gmail.com>
Subject: Re: Latency writing to an mlocked ext4 mapping
From: Andy Lutomirski <luto@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Wed, Oct 19, 2011 at 6:15 PM, Andy Lutomirski <luto@amacapital.net> wrot=
e:
> On Wed, Oct 19, 2011 at 6:02 PM, Andreas Dilger <adilger@dilger.ca> wrote=
:
>> What kernel are you using? =A0A change to keep pages consistent during w=
riteout was landed not too long ago (maybe Linux 3.0) in order to allow che=
cksumming of the data.
>
> 3.0.6, with no relevant patches. =A0(I have a one-liner added to the tcp
> code that I'll submit sometime soon.) =A0Would this explain the latency
> in file_update_time or is that a separate issue? =A0file_update_time
> seems like a good thing to make fully asynchronous (especially if the
> file in question is a fifo, but I've already moved my fifos to tmpfs).

On 2.6.39.4, I got one instance of:

call_rwsem_down_read_failed ext4_map_blocks ext4_da_get_block_prep
__block_write_begin ext4_da_write_begin ext4_page_mkwrite do_wp_page
handle_pte_fault handle_mm_fault do_page_fault page_fault

but I'm not seeing the large numbers of the ext4_page_mkwrite trace
that I get on 3.0.6.  file_update_time is now by far the dominant
cause of latency.

I'll leave it running overnight and see what happens.


--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
