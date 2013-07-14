Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A68866B0031
	for <linux-mm@kvack.org>; Sat, 13 Jul 2013 20:57:22 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id aq17so22182244iec.8
        for <linux-mm@kvack.org>; Sat, 13 Jul 2013 17:57:22 -0700 (PDT)
Message-ID: <51E1F769.7090208@gmail.com>
Date: Sun, 14 Jul 2013 08:57:13 +0800
From: Sam Ben <sam.bennn@gmail.com>
MIME-Version: 1.0
Subject: Re: RFC: named anonymous vmas
References: <CAMbhsRQU=xrcum+ZUbG3S+JfFUJK_qm_VB96Vz=PpL=vQYhUvg@mail.gmail.com> <20130622103158.GA16304@infradead.org> <CAMbhsRTz246dWPQOburNor2HvrgbN-AWb2jT_AEywtJHFbKWsA@mail.gmail.com> <kq4v0b$p8p$3@ger.gmane.org> <20130624114832.GA9961@infradead.org>
In-Reply-To: <20130624114832.GA9961@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alex Elsayed <eternaleye@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Christoph,
On 06/24/2013 07:48 PM, Christoph Hellwig wrote:
> On Sat, Jun 22, 2013 at 12:47:29PM -0700, Alex Elsayed wrote:
>> Couldn't this be done by having a root-only tmpfs, and having a userspace
>> component that creates per-app directories with restrictive permissions on
>> startup/app install? Then each app creates files in its own directory, and
>> can pass the fds around.
> Honestly having a device that allows passing fds around that can be
> mmaped sounds a lot simpler.  I have to admit that I expect /dev/zero
> to do this, but looking at the code it creates new file structures
> at ->mmap time which would defeat this.

Could you point out where done this?

>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
