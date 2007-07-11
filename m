From: "Matthew Hawkins" <darthmdh@gmail.com>
Subject: Re: Re: -mm merge plans for 2.6.23
Date: Wed, 11 Jul 2007 11:02:56 +1000
Message-ID: <b21f8390707101802o2d546477n2a18c1c3547c3d7a@mail.gmail.com>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	<200707102015.44004.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============22357674416594286=="
Return-path: <ck-bounces@vds.kolivas.org>
In-Reply-To: <200707102015.44004.kernel@kolivas.org>
List-Unsubscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=unsubscribe>
List-Archive: <http://bhhdoa.org.au/pipermail/ck>
List-Post: <mailto:ck@vds.kolivas.org>
List-Help: <mailto:ck-request@vds.kolivas.org?subject=help>
List-Subscribe: <http://bhhdoa.org.au/mailman/listinfo/ck>,
	<mailto:ck-request@vds.kolivas.org?subject=subscribe>
Sender: ck-bounces@vds.kolivas.org
Errors-To: ck-bounces@vds.kolivas.org
To: Con Kolivas <kernel@kolivas.org>
Cc: linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

--===============22357674416594286==
Content-Type: multipart/alternative;
	boundary="----=_Part_142421_17099742.1184115776248"

------=_Part_142421_17099742.1184115776248
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/10/07, Con Kolivas <kernel@kolivas.org> wrote:
>
> On Tuesday 10 July 2007 18:31, Andrew Morton wrote:
> > When replying, please rewrite the subject suitably and try to Cc: the
> > appropriate developer(s).
>
> ~swap prefetch

[snip]
Put me and the users out of our misery and merge it now
[snip]

For the record; it merges, builds, and runs cleanly on x86_64 vanilla+CFS
provided sched-add_above_background_load is also merged (you need the old
one that adds an inline to sched.h, not the new one that depends on
SD-isms).  I believe that is already merged with -mm anyway.

I'd also be interested to see if there is a better way of doing what
above_background_load() does with CFS, I think v18 added some functionality
along these lines...

We all know swap prefetch has been tested out the wazoo since Moses was a
little boy, is compile-time and runtime selectable, and gives an important
and quantifiable performance increase to desktop systems.  Save a Redhat
employee some time reinventing the wheel and just merge it.  This wheel
already has dope 21" rims, homes ;-)

-- 
Matt

------=_Part_142421_17099742.1184115776248
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 7/10/07, <b class="gmail_sendername">Con Kolivas</b> &lt;<a href="mailto:kernel@kolivas.org">kernel@kolivas.org</a>&gt; wrote:<div><span class="gmail_quote"></span><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
On Tuesday 10 July 2007 18:31, Andrew Morton wrote:<br>&gt; When replying, please rewrite the subject suitably and try to Cc: the<br>&gt; appropriate developer(s).<br><br>~swap prefetch</blockquote><div>[snip] <br></div>Put me and the users out of our misery and merge it now
</div>[snip]<br><br>For the record; it merges, builds, and runs cleanly on x86_64 vanilla+CFS provided sched-add_above_background_load is also merged (you need the old one that adds an inline to sched.h, not the new one that depends on SD-isms).&nbsp; I believe that is already merged with -mm anyway.
<br clear="all"><br>I&#39;d also be interested to see if there is a better way of doing what above_background_load() does with CFS, I think v18 added some functionality along these lines...<br><br>We all know swap prefetch has been tested out the wazoo since Moses was a little boy, is compile-time and runtime selectable, and gives an important and quantifiable performance increase to desktop systems.&nbsp; Save a Redhat employee some time reinventing the wheel and just merge it.&nbsp; This wheel already has dope 21&quot; rims, homes ;-)
<br><br>-- <br>Matt

------=_Part_142421_17099742.1184115776248--

--===============22357674416594286==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============22357674416594286==--
