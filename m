Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 7CA786B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 11:15:11 -0400 (EDT)
Message-ID: <1374074109.6458.144.camel@gandalf.local.home>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
From: Steven Rostedt <rostedt@goodmis.org>
Date: Wed, 17 Jul 2013 11:15:09 -0400
In-Reply-To: <0000013fed298406-22a9ee3c-e55c-4cc4-8a30-88fc02c8624d-000000@email.amazonses.com>
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
	 <1374063795.6458.125.camel@gandalf.local.home>
	 <0000013fed298406-22a9ee3c-e55c-4cc4-8a30-88fc02c8624d-000000@email.amazonses.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Clark Williams <williams@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <js1304@gmail.com>, Clark Williams <clark@redhat.com>, Glauber Costa <glommer@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

On Wed, 2013-07-17 at 15:04 +0000, Christoph Lameter wrote:
> On Wed, 17 Jul 2013, Steven Rostedt wrote:
> 
> > I was using the patch that Christoph posted. It was also attached to the
> > -rt kernel for 3.6. I could have backported the patch poorly too.
> 
> Could you try upstream?

Yeah, I'm running it now.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
