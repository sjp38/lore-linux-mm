Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 73B7A6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 00:20:52 -0400 (EDT)
Received: by mail-ie0-f171.google.com with SMTP id e11so77567iej.30
        for <linux-mm@kvack.org>; Mon, 15 Apr 2013 21:20:51 -0700 (PDT)
Message-ID: <516CD19C.6080508@gmail.com>
Date: Tue, 16 Apr 2013 12:20:44 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
References: <5114DF05.7070702@mellanox.com> <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com> <CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com> <516BBCB5.7050303@gmail.com> <CAH3drwYfC-pkgeokRB+tVpRmCiMAOk3b-EvL5kVpcxX-hM=kJQ@mail.gmail.com>
In-Reply-To: <CAH3drwYfC-pkgeokRB+tVpRmCiMAOk3b-EvL5kVpcxX-hM=kJQ@mail.gmail.com>
Content-Type: multipart/alternative;
 boundary="------------000405040503050909090509"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

This is a multi-part message in MIME format.
--------------000405040503050909090509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jerome,
On 04/15/2013 11:38 PM, Jerome Glisse wrote:
> On Mon, Apr 15, 2013 at 4:39 AM, Simon Jeons <simon.jeons@gmail.com 
> <mailto:simon.jeons@gmail.com>> wrote:
>
>     Hi Jerome,
>     On 02/10/2013 12:29 AM, Jerome Glisse wrote:
>
>         On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse
>         <walken@google.com <mailto:walken@google.com>> wrote:
>
>             On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel
>             <raindel@mellanox.com <mailto:raindel@mellanox.com>> wrote:
>
>                 Hi,
>
>                 We would like to present a reference implementation
>                 for safely sharing
>                 memory pages from user space with the hardware,
>                 without pinning.
>
>                 We will be happy to hear the community feedback on our
>                 prototype
>                 implementation, and suggestions for future improvements.
>
>                 We would also like to discuss adding features to the
>                 core MM subsystem to
>                 assist hardware access to user memory without pinning.
>
>             This sounds kinda scary TBH; however I do understand the
>             need for such
>             technology.
>
>             I think one issue is that many MM developers are
>             insufficiently aware
>             of such developments; having a technology presentation
>             would probably
>             help there; but traditionally LSF/MM sessions are more
>             interactive
>             between developers who are already quite familiar with the
>             technology.
>             I think it would help if you could send in advance a detailed
>             presentation of the problem and the proposed solutions
>             (and then what
>             they require of the MM layer) so people can be better
>             prepared.
>
>             And first I'd like to ask, aren't IOMMUs supposed to
>             already largely
>             solve this problem ? (probably a dumb question, but that
>             just tells
>             you how much you need to explain :)
>
>         For GPU the motivation is three fold. With the advance of GPU
>         compute
>         and also with newer graphic program we see a massive increase
>         in GPU
>         memory consumption. We easily can reach buffer that are bigger
>         than
>         1gbytes. So the first motivation is to directly use the memory the
>         user allocated through malloc in the GPU this avoid copying
>         1gbytes of
>         data with the cpu to the gpu buffer. The second and mostly
>         important
>
>
>     The pinned memory you mentioned is the memory user allocated or
>     the memory of gpu buffer?
>
>
> Memory user allocated, we don't want to pin this memory.

After this idea merged, we don't need to allocate memory for integrated 
GPU buffer and discrete GPU don't need to have its own memory, correct?

>
> Cheers,
> Jerome


--------------000405040503050909090509
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<html>
  <head>
    <meta content="text/html; charset=ISO-8859-1"
      http-equiv="Content-Type">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">Hi Jerome,<br>
      On 04/15/2013 11:38 PM, Jerome Glisse wrote:<br>
    </div>
    <blockquote
cite="mid:CAH3drwYfC-pkgeokRB+tVpRmCiMAOk3b-EvL5kVpcxX-hM=kJQ@mail.gmail.com"
      type="cite">
      <div class="gmail_quote">On Mon, Apr 15, 2013 at 4:39 AM, Simon
        Jeons <span dir="ltr">&lt;<a moz-do-not-send="true"
            href="mailto:simon.jeons@gmail.com" target="_blank">simon.jeons@gmail.com</a>&gt;</span>
        wrote:<br>
        <blockquote class="gmail_quote" style="margin:0 0 0
          .8ex;border-left:1px #ccc solid;padding-left:1ex">
          <div class="im">Hi Jerome,<br>
            On 02/10/2013 12:29 AM, Jerome Glisse wrote:<br>
          </div>
          <div>
            <div class="h5">
              <blockquote class="gmail_quote" style="margin:0 0 0
                .8ex;border-left:1px #ccc solid;padding-left:1ex">
                On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse &lt;<a
                  moz-do-not-send="true" href="mailto:walken@google.com"
                  target="_blank">walken@google.com</a>&gt; wrote:<br>
                <blockquote class="gmail_quote" style="margin:0 0 0
                  .8ex;border-left:1px #ccc solid;padding-left:1ex">
                  On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel &lt;<a
                    moz-do-not-send="true"
                    href="mailto:raindel@mellanox.com" target="_blank">raindel@mellanox.com</a>&gt;
                  wrote:<br>
                  <blockquote class="gmail_quote" style="margin:0 0 0
                    .8ex;border-left:1px #ccc solid;padding-left:1ex">
                    Hi,<br>
                    <br>
                    We would like to present a reference implementation
                    for safely sharing<br>
                    memory pages from user space with the hardware,
                    without pinning.<br>
                    <br>
                    We will be happy to hear the community feedback on
                    our prototype<br>
                    implementation, and suggestions for future
                    improvements.<br>
                    <br>
                    We would also like to discuss adding features to the
                    core MM subsystem to<br>
                    assist hardware access to user memory without
                    pinning.<br>
                  </blockquote>
                  This sounds kinda scary TBH; however I do understand
                  the need for such<br>
                  technology.<br>
                  <br>
                  I think one issue is that many MM developers are
                  insufficiently aware<br>
                  of such developments; having a technology presentation
                  would probably<br>
                  help there; but traditionally LSF/MM sessions are more
                  interactive<br>
                  between developers who are already quite familiar with
                  the technology.<br>
                  I think it would help if you could send in advance a
                  detailed<br>
                  presentation of the problem and the proposed solutions
                  (and then what<br>
                  they require of the MM layer) so people can be better
                  prepared.<br>
                  <br>
                  And first I'd like to ask, aren't IOMMUs supposed to
                  already largely<br>
                  solve this problem ? (probably a dumb question, but
                  that just tells<br>
                  you how much you need to explain :)<br>
                </blockquote>
                For GPU the motivation is three fold. With the advance
                of GPU compute<br>
                and also with newer graphic program we see a massive
                increase in GPU<br>
                memory consumption. We easily can reach buffer that are
                bigger than<br>
                1gbytes. So the first motivation is to directly use the
                memory the<br>
                user allocated through malloc in the GPU this avoid
                copying 1gbytes of<br>
                data with the cpu to the gpu buffer. The second and
                mostly important<br>
              </blockquote>
              <br>
            </div>
          </div>
          The pinned memory you mentioned is the memory user allocated
          or the memory of gpu buffer?<br>
        </blockquote>
      </div>
      <br>
      Memory user allocated, we don't want to pin this memory.<br>
    </blockquote>
    <br>
    After this idea merged, we don't need to allocate memory for
    integrated GPU buffer and discrete GPU don't need to have its own
    memory, correct?<br>
    <br>
    <blockquote
cite="mid:CAH3drwYfC-pkgeokRB+tVpRmCiMAOk3b-EvL5kVpcxX-hM=kJQ@mail.gmail.com"
      type="cite"><br>
      Cheers,<br>
      Jerome<br>
    </blockquote>
    <br>
  </body>
</html>

--------------000405040503050909090509--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
