Subject: Re: 2.5.62-mm2
From: Shawn <core@enodev.com>
In-Reply-To: <20030221184459.0d010ba1.akpm@digeo.com>
References: <20030220234733.3d4c5e6d.akpm@digeo.com>
	 <200302212048.09802.tomlins@cam.org>
	 <1045881657.27435.36.camel@localhost.localdomain>
	 <20030221184459.0d010ba1.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1045884393.3959.1.camel@localhost.localdomain>
Mime-Version: 1.0
Date: 21 Feb 2003 21:26:33 -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: tomlins@cam.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

And now it works. root fs never got mounted r/w. At first, I though is
was flaky h/w, and it may still be.

I'll watch closer, now that there has been some sort of similar
situation. That guy had two ctrlrs too.

On Fri, 2003-02-21 at 20:44, Andrew Morton wrote:
> Shawn <core@enodev.com> wrote:
> >
> > For some reason, I had to boot single, then go to multi user.
> > 
> > Otherwise, I got some sort  of interrupt not free messages after my
> > second ide ctrlr got recognized.
> > 
> 
> You'll need to transcribe that message and send your full dmesg
> output please.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
