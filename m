Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 8540E6B0032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 13:26:58 -0400 (EDT)
Received: by mail-ve0-f180.google.com with SMTP id pa12so8925106veb.25
        for <linux-mm@kvack.org>; Mon, 24 Jun 2013 10:26:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130624114832.GA9961@infradead.org>
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com>
	<20130622103158.GA16304@infradead.org>
	<CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com>
	<kq4v0b$p8p$3@ger.gmane.org>
	<20130624114832.GA9961@infradead.org>
Date: Mon, 24 Jun 2013 10:26:57 -0700
Message-ID: <CAMbhsRTdMaVR1LZRigumDqz_e5FgeyfJLrSHCDs8t7ywrmumTQ@mail.gmail.com>
Subject: Re: RFC: named anonymous vmas
From: Colin Cross <ccross@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alex Elsayed <eternaleye@gmail.com>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Mon, Jun 24, 2013 at 4:48 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Sat, Jun 22, 2013 at 12:47:29PM -0700, Alex Elsayed wrote:
>> Couldn't this be done by having a root-only tmpfs, and having a userspace
>> component that creates per-app directories with restrictive permissions on
>> startup/app install? Then each app creates files in its own directory, and
>> can pass the fds around.

If each app gets its own writable directory that's not really
different than a world writable tmpfs.  It requires something that
watches for apps to exit for any reason and cleans up their
directories, and it requires each app to come up with an unused name
when it wants to create a file, and the kernel can give you both very
cleanly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
