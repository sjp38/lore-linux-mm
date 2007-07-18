From: "Bart Van Assche" <bart.vanassche@gmail.com>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access
	of bad area during boot with DEBUG_SLAB=y
Date: Wed, 18 Jul 2007 20:43:46 +0200
Message-ID: <e2e108260707181143x98760a9gf1734eaaf897cee8@mail.gmail.com>
References: <bug-8778-10286@http.bugzilla.kernel.org/>
	<20070718005253.942f0464.akpm@linux-foundation.org>
	<20070718083425.GA29722@gate.ebshome.net>
	<1184766070.3699.2.camel@zod.rchland.ibm.com>
	<20070718155940.GB29722@gate.ebshome.net>
	<20070718095537.d344dc0a.akpm@linux-foundation.org>
	<20070718170433.GC29722@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1603235888=="
Return-path: <linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <20070718170433.GC29722@gate.ebshome.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Mime-version: 1.0
Sender: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-embedded-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
To: Eugene Surovegin <ebs@ebshome.net>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>, linuxppc-embedded@ozlabs.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-Id: linux-mm.kvack.org

--===============1603235888==
Content-Type: multipart/alternative;
	boundary="----=_Part_101522_6960589.1184784226940"

------=_Part_101522_6960589.1184784226940
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/18/07, Eugene Surovegin <ebs@ebshome.net> wrote:
>
>
> It's kmalloc, at least this is how I think skbs are allocated.
>
> Andrew, I don't have access to PPC hw right now (doing MIPS
> development these days), so I cannot quickly check that my theory is
> still correct for the latest kernel. I'd wait for the reporter to try
> my hack and then we can decide what to do. IIRC there was some
> provision in slab allocator to enforce alignment, when I was debugging
> this problem more then a year ago, that option didn't work.
>
> BTW, I think slob allocator had the same issue with alignment as slab
> with enabled debugging (at least at the time I looked at it).



Hello Eugene,

In case you didn't notice yet, I have added the following comment to the
kernel bugzilla item:


------- *Comment #5
<http://bugzilla.kernel.org/show_bug.cgi?id=8778#c5>From Bart
Van Assche <bart.vanassche@gmail.com> 2007-07-18 07:12:49 *
[reply<http://bugzilla.kernel.org/show_bug.cgi?id=8778#add_comment>]
-------

I have downloaded the patch from
http://kernel.ebshome.net/emac_slab_debug.diff, and I have tried it. Hereby I
confirm that this patch solves the reported kernel oops.



-- 
Regards,

Bart Van Assche.

------=_Part_101522_6960589.1184784226940
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/18/07, <b class="gmail_sendername">Eugene Surovegin</b> &lt;<a href="mailto:ebs@ebshome.net">ebs@ebshome.net</a>&gt; wrote:<div><span class="gmail_quote"></span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
<br>It&#39;s kmalloc, at least this is how I think skbs are allocated.<br><br>Andrew, I don&#39;t have access to PPC hw right now (doing MIPS<br>development these days), so I cannot quickly check that my theory is<br>still correct for the latest kernel. I&#39;d wait for the reporter to try
<br>my hack and then we can decide what to do. IIRC there was some<br>provision in slab allocator to enforce alignment, when I was debugging<br>this problem more then a year ago, that option didn&#39;t work.<br><br>BTW, I think slob allocator had the same issue with alignment as slab
<br>with enabled debugging (at least at the time I looked at it).</blockquote><div><br><br>Hello Eugene,<br><br>In case you didn&#39;t notice yet, I  have added the following comment to the kernel bugzilla item:<br></div>
<br></div><br><span class="bz_comment">
          ------- <i>Comment
          <a name="c5" href="http://bugzilla.kernel.org/show_bug.cgi?id=8778#c5">
            #5</a> From 
          <a href="mailto:bart.vanassche@gmail.com">Bart Van Assche</a>
          2007-07-18 07:12:49 
          </i>
          [<a href="http://bugzilla.kernel.org/show_bug.cgi?id=8778#add_comment" onclick="replyToComment(5);">reply</a>]
          -------
        </span>
        


<pre id="comment_text_5">I have downloaded the patch from<br><a href="http://kernel.ebshome.net/emac_slab_debug.diff">http://kernel.ebshome.net/emac_slab_debug.diff</a>, and I have tried it. Hereby I<br>confirm that this patch solves the reported kernel oops.
<br></pre><br clear="all"><br>-- <br>Regards,<br><br>Bart Van Assche.

------=_Part_101522_6960589.1184784226940--

--===============1603235888==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Linuxppc-embedded mailing list
Linuxppc-embedded@ozlabs.org
https://ozlabs.org/mailman/listinfo/linuxppc-embedded
--===============1603235888==--
