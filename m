From: Rodrigo S de Castro <rodsc@terra.com.br>
Subject: Re: why its dead now?
Date: Mon, 14 Nov 2005 17:58:52 -0200
References: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com>
In-Reply-To: <f68e01850511131035l3f0530aft6076f156d4f62171@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511141758.52171.rodsc@terra.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nitin Gupta <nitingupta.mail@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Nitin,

I didn't know you were working on a port of it to 2.6 version. 

The project has been dead because I didn't have time to work on it after I 
finished my Master's degree and also because nobody showed interest and had 
enough time to port it to 2.6. Although it was not completely stable, it has 
been used in many patchsets (ck, wolk) and I had really good feedbacks from 
its users, in particular desktop users about smoother system degradations 
when under memory pressure. It has never been officialy announced since there 
is still a good deal of work to make it work with high memory systems, to 
make it thread safe and probably some more testing and adjustments. With 2.6, 
we still have rmap implementation that may help us improving the dynamic 
adaptivity heuristic. 

Answering your questions, from my experience developing the 2.4 version, it 
doesn't seem to have any serious drawbacks, but it has not yet been 
extensively tested to prove to be a valid idea (although our benchmarks show 
to be) and it didn't reach an implementation level where it could be 
considered to be possibly a configuration option, at least. I think it may be 
really useful to port it to 2.6, for various reasons, such as:

- better change to prove this concept, 
- it may turn out to be a good option for embedded systems, 
- chance to improve the adaptivity heuristic (with rmap and maybe with other 
2.6 mm updates, besides some ideas I have)
- with a thread safe, see how well it works with SMP systems.

I am interested in porting it to 2.6 and it's possible, although not yet sure, 
that I get back to working on this project in the next weeks. Let's discuss 
the status of your port and how we could work together to make it happen (we 
could discuss further on the lc-devel list).

Best regards,

Rodrigo


On Sunday 13 November 2005 16:35, Nitin Gupta wrote:
> Hi,
>     I've been working on 'compressed cache' feature
> (http://linuxcompressed.sourceforge.net/) for some time now. I'm
> basically porting it to 2.6 kernel series as it has already been
> developed for 2.4.x kernels.
>    I'm wondering why this project is dead even when it showed great
> performance improvement when system is under memory pressure.
>
> Are there any serious drawbacks to this?
> Do you think it will be of any use if ported to 2.6 kernel?
>
> Your feedback will be really helpful.
>
> Thanks
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
