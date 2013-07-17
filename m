Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 54BED6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 08:23:21 -0400 (EDT)
Message-ID: <1374063795.6458.125.camel@gandalf.local.home>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 17 Jul 2013 08:23:15 -0400
In-Reply-To: <CAOJsxLGj8BVUPAXCshtcSfxFjqHzm6+_HdyRsEazhv-gp4XcNA@mail.gmail.com>
References: <20130614195500.373711648@linux.com>
	 <0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
	 <51BFFFA1.8030402@kernel.org>
	 <0000013f57a5b278-d9104e1e-ccec-40ec-bd95-f8b0816a38d9-000000@email.amazonses.com>
	 <20130618102109.310f4ce1@riff.lan>
	 <CAOJsxLHsYVThWL7yKEQaQqxTSpgK8RHm-u8n94t_m4=uMjDqzw@mail.gmail.com>
	 <1372170272.18733.201.camel@gandalf.local.home>
	 <0000013f9b735739-eb4b29ce-fbc6-4493-ac56-22766da5fdae-000000@email.amazonses.com>
	 <20130702100913.0ef4cd25@riff.lan>
	 <0000013fa047b23e-84298a70-911d-43ea-9db3-bc9682bb90b6-000000@email.amazonses.com>
	 <1374029203.6458.121.camel@gandalf.local.home>
	 <CAOJsxLGj8BVUPAXCshtcSfxFjqHzm6+_HdyRsEazhv-gp4XcNA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Clark Williams <williams@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <js1304@gmail.com>, Clark Williams <clark@redhat.com>, Glauber Costa <glommer@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Wed, 2013-07-17 at 10:04 +0300, Pekka Enberg wrote:
> Hi Steven,
> 
> On Wed, Jul 17, 2013 at 5:46 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> > When I run a stress test of the box (kernel compile along with
> > hackbench), with that patch applied, the system hangs for long periods
> > of time. I have no idea why, but the oom killer would trigger
> > constantly.
> 
> Are you using this patch or the modified version by Joonsoo that
> landed in Linus' tree?

I was using the patch that Christoph posted. It was also attached to the
-rt kernel for 3.6. I could have backported the patch poorly too.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
